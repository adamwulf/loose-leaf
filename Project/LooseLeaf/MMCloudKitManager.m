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
#import <ZipArchive/ZipArchive.h>

@implementation MMCloudKitManager{
    MMCloudKitBaseState* currentState;
}

@synthesize delegate;
@synthesize currentState;

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudKitInfoDidChange) name:NSUbiquityIdentityDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
        
        currentState = [[MMCloudKitBaseState alloc] init];
        
        // the UIApplicationDidBecomeActiveNotification will kickstart the process when the app launches
    }
    return self;
}

+ (MMCloudKitManager *) sharedManager {
    static dispatch_once_t onceToken;
    static MMCloudKitManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MMCloudKitManager alloc] init];
    });
    return manager;
}

+(BOOL) isCloudKitAvailable{
    return [CKContainer class] != nil;
}

-(void) userRequestedToLogin{
    MMCloudKitBaseState* currentState = [[MMCloudKitManager sharedManager] currentState];
    if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        [(MMCloudKitWaitingForLoginState*)currentState didAskToLogin];
    }
}

-(void) changeToState:(MMCloudKitBaseState*)state{
    currentState = state;
    [currentState runState];
    [self.delegate cloudKitDidChangeState:currentState];
}

-(void) retryStateAfterDelay{
    [self performSelector:@selector(delayedRunStateFor:) withObject:currentState afterDelay:1];
}

-(void) delayedRunStateFor:(MMCloudKitBaseState*)aState{
    if(currentState == aState){
        [aState runState];
    }
}

-(BOOL) isLoggedInAndReadyForAnything{
    return [currentState isKindOfClass:[MMCloudKitLoggedInState class]];
}

#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    // handle change in cloudkit
    [currentState cloudKitInfoDidChange];
}

-(void) applicationDidBecomeActive{
    [currentState applicationDidBecomeActive];
}

-(void) reachabilityDidChange{
    [currentState reachabilityDidChange];
}


#pragma mark - Remote Notification

-(void) handleIncomingMessageNotification:(CKQueryNotification*)remoteNotification{
    [[SPRSimpleCloudKitManager sharedManager] messageForQueryNotification:remoteNotification withCompletionHandler:^(SPRMessage *message, NSError *error) {
        // Do something with the message, like pushing it onto the stack
        [[SPRSimpleCloudKitManager sharedManager] fetchDetailsForMessage:message withCompletionHandler:^(SPRMessage *message, NSError *error) {
            if(!error){
                [self handleIncomingMessage:message];
            }else{
                NSLog(@"invalid zip file");
                [delegate didFailToFetchMessage:remoteNotification.recordID withProperties:remoteNotification.recordFields];
            }
        }];
    }];
    [self.currentState cloudKitDidRecievePush];
}

-(void) handleIncomingMessage:(SPRMessage *)message{
    NSLog(@"processing incoming message: %@", message.messageRecordID);
    ZipArchive* zip = [[ZipArchive alloc] init];
    if([zip validateZipFileAt:message.messageData.path]){
        NSLog(@"valid zip file");
        NSLog(@"message from: %@ %@ at %@", message.senderFirstName, message.senderLastName, message.messageData.path);
        [delegate didRecieveMessageFrom:message.sender forZip:message.messageData.path];
    }else{
        NSLog(@"invalid zip file");
        NSLog(@"zip at: %@", message.messageData.path);
        if(message.messageData.path){
            NSString* savedPath = [[NSFileManager documentsPath] stringByAppendingPathComponent:[message.messageData.path lastPathComponent]];
            [[NSFileManager defaultManager] moveItemAtPath:message.messageData.path toPath:savedPath error:nil];
            NSLog(@"saved to: %@", savedPath);
        }
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
