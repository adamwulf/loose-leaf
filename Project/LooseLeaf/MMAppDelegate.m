//
//  MMAppDelegate.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMAppDelegate.h"

#import "MMLooseLeafViewController.h"
#import "MMRotationManager.h"
#import "MMInboxManager.h"
#import "NSString+UUID.h"
#import "SSKeychain.h"
#import "Mixpanel.h"
#import "MMWindow.h"
#import "MMCloudKitManager.h"
#import "TestFlight.h"


@implementation MMAppDelegate{
    CFAbsoluteTime sessionStartStamp;
    NSTimer* durationTimer;
    CFAbsoluteTime resignedActiveAtStamp;
}

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    debug_NSLog(@"DID FINISH LAUNCHING");
    [Crashlytics startWithAPIKey:@"9e59cb6d909c971a2db30c84cb9be7f37273a7af"];
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    [[Mixpanel sharedInstance] identify:[MMAppDelegate userID]];
    [[Mixpanel sharedInstance] registerSuperProperties:[NSDictionary dictionaryWithObjectsAndKeys:@([[UIScreen mainScreen] scale]), kMPScreenScale, nil]];
    
    [[NSThread mainThread] performBlock:^{
        [TestFlight setOptions:@{ TFOptionReportCrashes : @NO }];
        [TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
        [TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];
        [TestFlight setOptions:@{ TFOptionLogOnCheckpoint : @NO }];
        [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
        [TestFlight takeOff:kTestflightAppToken];
    } afterDelay:3];
    
    self.window = [[MMWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MMLooseLeafViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
//    [self.window.layer setSpeed:0.3f];

    // setup the timer that will help log session duration
    [self setupTimer];
    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSString* sourceApplication = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    if(url){
        [self importFileFrom:url fromApp:sourceApplication];
    }

    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            [self checkForNotificationToHandleWithNotificationInfo:dictionary];
        }
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    debug_NSLog(@"WILL RESIGN ACTIVE");
    [self.viewController willResignActive];
    [[MMRotationManager sharedInstance] willResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    resignedActiveAtStamp = CFAbsoluteTimeGetCurrent();
    [self logActiveAppDuration];
    [durationTimer invalidate];
    durationTimer = nil;
    [[MMRotationManager sharedInstance] applicationDidBackground];
    debug_NSLog(@"DID ENTER BACKGROUND");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    debug_NSLog(@"WILL ENTER FOREGROUND");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setupTimer];
    if((CFAbsoluteTimeGetCurrent() - resignedActiveAtStamp) / 60.0 > 5){
        // they resigned active over 5 minutes ago, treat this
        // as a new launch
        //
        // this'll also trigger when the app first launches, as resignedActiveStamp == 0
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfLaunches by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventLaunch];
    };
    [[MMRotationManager sharedInstance] didBecomeActive];
    debug_NSLog(@"DID BECOME ACTIVE");
    debug_NSLog(@"***************************************************************************");
    debug_NSLog(@"***************************************************************************");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self logActiveAppDuration];
    [durationTimer invalidate];
    durationTimer = nil;
    debug_NSLog(@"WILL TERMINATE");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url) {
        [self importFileFrom:url fromApp:sourceApplication];
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
    NSLog(@"==== recieved notification!");
    // Do something if the app was in background. Could handle foreground notifications differently
    if (application.applicationState == UIApplicationStateActive) {
        // notification came through while app was open
        [self checkForNotificationToHandleWithNotificationInfo:info];
    }else{
        // notification came through while app was in background.
        // tapping on a notification to launch the app will also
        // land here.
        [self checkForNotificationToHandleWithNotificationInfo:info];
    }
}

-(void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    NSLog(@"what");
}

-(void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSLog(@"what");
}

- (void) checkForNotificationToHandleWithNotificationInfo:(NSDictionary *)userInfo {
    CKQueryNotification *notification = [CKQueryNotification notificationFromRemoteNotificationDictionary:userInfo];
    if([notification isKindOfClass:[CKQueryNotification class]]){
        if(notification.notificationType == CKNotificationTypeQuery){
            [[MMCloudKitManager sharedManager] handleIncomingMessageNotification:notification];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
}

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"did fail register for remote notifications");
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier{
    NSLog(@"extension? %@", extensionPointIdentifier);
    return YES;
}

#pragma mark - Photo and PDF Import

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication{
    if(!sourceApplication) sourceApplication = @"app.unknown";
    // need to have a reference to this, because
    // calling url.pathExtension seems to immediately dealloc
    // the path extension when i pass it into the dict below
    [self.viewController importFileFrom:url fromApp:sourceApplication];
}



#pragma mark - Session Duration

-(void) logActiveAppDuration{
    [[[Mixpanel sharedInstance] people] increment:kMPDurationAppOpen by:@((CFAbsoluteTimeGetCurrent() - sessionStartStamp) / 60.0)];
}

-(void) setupTimer{
    sessionStartStamp = CFAbsoluteTimeGetCurrent();
    // track every five minutes that the app is open
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 5
                                                     target:self
                                                   selector:@selector(durationTimerDidFire:)
                                                   userInfo:nil
                                                    repeats:YES];
}

-(void) durationTimerDidFire:(NSTimer*)timer{
    [self logActiveAppDuration];
    sessionStartStamp = CFAbsoluteTimeGetCurrent();
}


#pragma mark - User UUID

+(NSString*) userID{
    NSString *uuid = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:@"userID"];
    if(!uuid){
        uuid = [NSString createStringUUID];
        [SSKeychain setPassword:uuid forService:[[NSBundle mainBundle] bundleIdentifier] account:@"userID"];
    }
    return uuid;
}


@end
