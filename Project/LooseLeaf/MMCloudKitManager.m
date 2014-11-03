//
//  MMCloudKitManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitManager.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>
#import "NSThread+BlockAdditions.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitDeclinedPermissionState.h"
#import "MMCloudKitAccountMissingState.h"
#import "MMCloudKitAskingForPermissionState.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitWaitingForLoginState.h"
#import "MMCloudKitLoggedInState.h"
#import "MMCloudKitFetchFriendsState.h"
#import "MMCloudKitFetchingAccountInfoState.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSArray+Extras.h"
#import <ZipArchive/ZipArchive.h>
#import "Constants.h"

#define kMessagesSinceLastFetchKey @"messagesSinceLastFetch"

@implementation MMCloudKitManager{
    MMCloudKitBaseState* currentState;
    NSString* cachePath;
    
    NSMutableDictionary* incomingMessageState;
    
    BOOL needsBootstrap;
    CKModifyBadgeOperation * lastBadgeOp;
}

@synthesize delegate;
@synthesize currentState;

static dispatch_queue_t messageQueue;

+(dispatch_queue_t) messageQueue{
    if(!messageQueue){
        messageQueue = dispatch_queue_create("com.milestonemade.looseleaf.cloudkit.messageQueue", DISPATCH_QUEUE_SERIAL);
    }
    return messageQueue;
}

static NSString* cloudKitFilesPath;

+(NSString*) cloudKitFilesPath{
    if(!cloudKitFilesPath){
        cloudKitFilesPath = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"CloudKit"];
        [NSFileManager ensureDirectoryExistsAtPath:cloudKitFilesPath];
    }
    return cloudKitFilesPath;
}

+ (MMCloudKitManager *) sharedManager {
    static dispatch_once_t onceToken;
    static MMCloudKitManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MMCloudKitManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        needsBootstrap = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudKitInfoDidChange) name:NSUbiquityIdentityDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
        
        [MMCloudKitBaseState clearCache];
        currentState = [[MMCloudKitLoggedInState alloc] initWithCachedFriendList:@[]];
        
        dispatch_async([MMCloudKitManager messageQueue], ^{
            @autoreleasepool {
                incomingMessageState = [NSMutableDictionary dictionaryWithContentsOfFile:[[self cachePath] stringByAppendingPathComponent:@"messages.plist"]];
                if(!incomingMessageState){
                    incomingMessageState = [NSMutableDictionary dictionary];
                    [incomingMessageState setObject:@[] forKey:kMessagesSinceLastFetchKey];
                }
            }
        });
        
        // the UIApplicationDidBecomeActiveNotification will kickstart the process when the app launches
    }
    return self;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString*) cachePath{
    if(!cachePath){
        NSString* documentsPath = [NSFileManager documentsPath];
        cachePath = [documentsPath stringByAppendingPathComponent:@"CloudKit"];
        [NSFileManager ensureDirectoryExistsAtPath:cachePath];
    }
    return cachePath;
}

#pragma mark - Status

+(BOOL) isCloudKitAvailable{
    return [CKContainer class] != nil;
}

-(BOOL) isLoggedInAndReadyForAnything{
    return [currentState isLoggedInAndReadyForAnything];
}

#pragma mark - Events

-(void) userRequestedToLogin{
    if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        [(MMCloudKitWaitingForLoginState*)currentState didAskToLogin];
    }
}

-(void) didBecomeActive{
    if(needsBootstrap){
        needsBootstrap = NO;
        [currentState runState];
    }
}

-(void) fetchAllNewMessages{
    [[SPRSimpleCloudKitManager sharedManager] fetchNewMessagesAndMarkAsReadWithCompletionHandler:^(NSArray *messages, NSError *error) {
        if(!error){
            DebugLog(@"CloudKit fetched all new messages: %d", (int) [messages count]);
            for(SPRMessage* message in messages){
                [self processIncomingMessage:message];
            }
            [currentState cloudKitDidCheckForNotifications];
            
            // clear out any messages that we're tracking
            // since our last fetch-all-notifications
            dispatch_async([MMCloudKitManager messageQueue], ^{
                @autoreleasepool {
                    @synchronized(incomingMessageState){
                        [incomingMessageState setObject:[NSArray array] forKey:kMessagesSinceLastFetchKey];
                    }
                }
            });
        }else{
            [currentState cloudKitDidCheckForNotifications];
        }
    }];
}


-(void) processIncomingMessage:(SPRMessage*)unprocessedMessage{
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);

    __block BOOL hadAlreadyProcessedThisMessage = NO;
    // first, check to make sure that we haven't already processed
    // this message yet. if we have, then we should just
    // bail out here.
    dispatch_async([MMCloudKitManager messageQueue], ^{
        @autoreleasepool {
            @synchronized(incomingMessageState){
                NSArray* messagesSinceLastFetch = [incomingMessageState objectForKey:kMessagesSinceLastFetchKey];
                hadAlreadyProcessedThisMessage = [messagesSinceLastFetch containsObject:unprocessedMessage];
                if(!hadAlreadyProcessedThisMessage){
                    // if we haven't processed it yet, then go ahead
                    // and mark it as processed
                    [incomingMessageState setObject:[messagesSinceLastFetch arrayByAddingObject:unprocessedMessage] forKey:kMessagesSinceLastFetchKey];
                }
            }
        }
        dispatch_semaphore_signal(sema1);
    });
    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
    
    if(hadAlreadyProcessedThisMessage){
        // we'd already handle this message, so we can
        // safely bail out here. this happens when we
        // recieve the push notificatio, and also recieve it
        // again when fetching all new messages.
        return;
    }

    [delegate didFetchMessage:unprocessedMessage];
}

#pragma mark - State Management


-(void) changeToState:(MMCloudKitBaseState*)state{
    // cancel any pending calls to the old state
    [currentState killState];
    currentState = state;
    [currentState runState];
    [self.delegate cloudKitDidChangeState:currentState];
}

-(void) retryStateAfterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(delayedRunStateFor:) withObject:currentState afterDelay:delay];
}

-(void) delayedRunStateFor:(MMCloudKitBaseState*)aState{
    if(currentState == aState){
        [aState runState];
    }
}

-(void) changeToStateBasedOnError:(NSError*)err{
    DebugLog(@"changeToStateBasedOnError: %@", err);
    [MMCloudKitBaseState clearCache];
    switch (err.code) {
        case SPRSimpleCloudMessengerErrorNetwork:
        case SPRSimpleCloudMessengerErrorServiceUnavailable:
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErroriCloudAccount:
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitAccountMissingState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErrorMissingDiscoveryPermissions:
            // right now the ONLY permission is for discovery
            // if that changes in the future, will want to make this more accurate
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitDeclinedPermissionState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErrorRateLimit:
            // network command was somehow cancelled, so re-run it
            [[MMCloudKitManager sharedManager] retryStateAfterDelay:10];
            break;
        case SPRSimpleCloudMessengerErrorUnexpected:
            [[MMCloudKitManager sharedManager] retryStateAfterDelay:1];
            break;
    }
}

#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    // handle change in cloudkit
    [MMCloudKitBaseState clearCache];
    [currentState cloudKitInfoDidChange];
}

-(void) applicationWillEnterForeground{
    DebugLog(@"applicationWillEnterForeground - cloudkit manager");
    [MMCloudKitBaseState clearCache];
    [self changeToState:[[MMCloudKitBaseState alloc] initWithCachedFriendList:currentState.friendList]];
    [self fetchAllNewMessages];
}

-(void) reachabilityDidChange{
    [currentState reachabilityDidChange];
}

#pragma mark - Remote Notification

-(void) handleIncomingMessageNotification:(CKQueryNotification*)remoteNotification{
    [[SPRSimpleCloudKitManager sharedManager] messageForQueryNotification:remoteNotification withCompletionHandler:^(SPRMessage *message, NSError *error) {
        // notify that we're going to fetch message details
        [self processIncomingMessage:message];
    }];
    [self.currentState cloudKitDidRecievePush];
    [self fetchAllNewMessages];
}

-(void) resetBadgeCountTo:(NSUInteger)number{
    if(!lastBadgeOp){
        CKModifyBadgeOperation *oper = [[CKModifyBadgeOperation alloc] initWithBadgeValue:number];
        oper.modifyBadgeCompletionBlock = ^(NSError* err){
            lastBadgeOp = nil;
            if(!err){
                UIUserNotificationSettings* notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
                if (notificationSettings.types & UIUserNotificationTypeBadge){
                    [UIApplication sharedApplication].applicationIconBadgeNumber = number;
                    DebugLog(@"reset badge count to: %d", (int) number);
                    [self.delegate didResetBadgeCountTo:number];
                }
            }
        };
        [[CKContainer defaultContainer] addOperation:oper];
    }
}

#pragma mark - Description

-(NSString*) description{
    if([currentState isKindOfClass:[MMCloudKitFetchingAccountInfoState class]]){
        return @"loading account info";
    }else if([currentState isKindOfClass:[MMCloudKitFetchFriendsState class]]){
        return @"loading friends";
    }else if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        return @"logged in";
    }else if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        return @"Needs User to Login";
    }else if([currentState isKindOfClass:[MMCloudKitAskingForPermissionState class]]){
        return @"Asking for permission";
    }else if([currentState isKindOfClass:[MMCloudKitOfflineState class]]){
        return @"Network Offline";
    }else if([currentState isKindOfClass:[MMCloudKitAccountMissingState class]]){
        return @"No Account";
    }else if([currentState isKindOfClass:[MMCloudKitDeclinedPermissionState class]]){
        return @"Permission Denied";
    }else{
        return @"initializing cloudkit";
    }
}
@end
