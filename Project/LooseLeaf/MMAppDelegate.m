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
#import "MMPresentationWindow.h"
#import "UIDevice+PPI.h"
#import "UIApplication+Version.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import <JotUI/JotUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MMUnknownObject.h"
#import "MMAllStacksManager.h"
@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;


@implementation MMAppDelegate {
    CFAbsoluteTime sessionStartStamp;
    NSTimer* durationTimer;
    CFAbsoluteTime resignedActiveAtStamp;
    BOOL didRecieveReportFromCrashlytics;
    BOOL isActive;
}

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize presentationWindow;
@synthesize isActive = isActive;

static BOOL isFirstLaunch = NO;

+ (void)load {
    NSString* uuid = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:@"userID"];
    if (!uuid) {
        isFirstLaunch = YES;
    }
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    DebugLog(@"Documents path: %@", [NSFileManager documentsPath]);

    NSString* email = [[NSUserDefaults standardUserDefaults] stringForKey:kPendingEmailToSubscribe];

    if (email) {
        // make sure its in keychain too
        [MMAppDelegate setEmail:email];
    }

    NSURL* appIdsURL = [[NSBundle mainBundle] URLForResource:@"AppIds" withExtension:@"plist"];
    NSDictionary* appIds = [[NSDictionary alloc] initWithContentsOfURL:appIdsURL];

    [MSAppCenter start:[appIds objectForKey:@"AppCenter"] withServices:@[
        [MSAnalytics class],
        [MSCrashes class]
    ]];

    if ([MSCrashes hasCrashedInLastSession]) {
        [self crashlyticsDidCrashDuringPreviousExecution];
    }

    // support old archives
    [NSKeyedUnarchiver setClass:[MMUnknownObject class] forClassName:@"MMCloudKitTutorialImportCoordinator"];

    isActive = YES;

    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    [[Mixpanel sharedInstance] identify:[MMAppDelegate userID]];
    [[[Mixpanel sharedInstance] people] set:kMPID to:[MMAppDelegate userID]];

    dispatch_async(dispatch_get_background_queue(), ^{
        NSString* str = [MMAppDelegate userID];
        NSInteger loc1 = [str rangeOfString:@"-"].location;
        NSInteger loc2 = [str rangeOfString:@"-" options:NSLiteralSearch range:NSMakeRange(loc1 + 1, [str length] - loc1 - 1)].location;
        str = [str substringToIndex:loc2];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:kMixpanelUUID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });

    [[Mixpanel sharedInstance] registerSuperProperties:[NSDictionary dictionaryWithObjectsAndKeys:@([[UIScreen mainScreen] scale]), kMPScreenScale,
                                                                                                  [UIDevice modelName], kMPiPadModel,
                                                                                                  [MMAppDelegate userID], kMPID, nil]];

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];


    [[MMAllStacksManager sharedInstance] upgradeIfNecessary:^{
        if (![[[MMAllStacksManager sharedInstance] stackIDs] count]) {
            [[MMAllStacksManager sharedInstance] createStack:YES];
        }

        presentationWindow = [[MMPresentationWindow alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
        [presentationWindow makeKeyAndVisible];

        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        self.window = [[MMWindow alloc] initWithFrame:screenBounds];
        // Override point for customization after application launch.
        self.viewController = [[MMLooseLeafViewController alloc] init];
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];

        //    [self.window.layer setSpeed:0.1f];

        // setup the timer that will help log session duration
        [self setupTimer];
    }];

    NSDate* dateOfCrash = [self dateOfDeathIfAny];
    [[NSThread mainThread] performBlock:^{
        if (dateOfCrash && !didRecieveReportFromCrashlytics) {
            // we shouldn't have a kAppLaunchStatus if we shut down correctly,
            // log as a possible memory crash or user force-close
            [self trackDidCrashFromMemoryForDate:dateOfCrash];
        }
    } afterDelay:5];

    return YES;
}

// Handle deeplinking back to app from Pinterest
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    DebugLog(@"Opened by handling url: %@", [url absoluteString]);

    return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DebugLog(@"WILL RESIGN ACTIVE");
    isActive = NO;
    [[MMRotationManager sharedInstance] willResignActive];
    [self.viewController willResignActive];
    // stop the timer once "App Close" event is called
    [[Mixpanel sharedInstance] track:kMPEventActiveSession properties:@{ @"First Launch": @(isFirstLaunch) }];
    [[Mixpanel sharedInstance] track:kMPEventResign properties:@{ @"First Launch": @(isFirstLaunch) }];
    [[Mixpanel sharedInstance] flush];
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    isActive = NO;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    resignedActiveAtStamp = CFAbsoluteTimeGetCurrent();
    [self logActiveAppDuration];
    [self stopTimer];
    [[MMRotationManager sharedInstance] applicationDidBackground];
    [self removeDateOfLaunch];
    [self.viewController didEnterBackground];
    [[JotDiskAssetManager sharedManager] blockUntilAllWritesHaveFinished];
    DebugLog(@"DID ENTER BACKGROUND");
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
    isActive = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DebugLog(@"WILL ENTER FOREGROUND");
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    [FBSDKAppEvents activateApp];
    isActive = YES;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setupTimer];
    if ((CFAbsoluteTimeGetCurrent() - resignedActiveAtStamp) / 60.0 > 5) {
        // they resigned active over 5 minutes ago, treat this
        // as a new launch
        //
        // this'll also trigger when the app first launches, as resignedActiveStamp == 0
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfLaunches by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventLaunch properties:@{ @"First Launch": @(isFirstLaunch) }];
    } else {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfResumes by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventResume properties:@{ @"First Launch": @(isFirstLaunch) }];
    }
    [[MMRotationManager sharedInstance] didBecomeActive];
    [self saveDateOfLaunch];
    // start the timer for the event "App Close"
    [[Mixpanel sharedInstance] timeEvent:kMPEventActiveSession];

    DebugLog(@"DID BECOME ACTIVE");
    DebugLog(@"***************************************************************************");
    DebugLog(@"***************************************************************************");
}

- (void)applicationWillTerminate:(UIApplication*)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self logActiveAppDuration];
    [self stopTimer];
    [self removeDateOfLaunch];
    [[Mixpanel sharedInstance] flush];
    DebugLog(@"WILL TERMINATE");
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];

    if (url) {
        [self importFileFrom:url fromApp:sourceApplication];
    }
    return YES;
}

- (void)application:(UIApplication*)application handleEventsForBackgroundURLSession:(NSString*)identifier completionHandler:(nonnull void (^)(void))completionHandler {
    DebugLog(@"handleEventsForBackgroundURLSession");
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [[[Mixpanel sharedInstance] people] set:kMPPushEnabled to:@(YES)];
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [[[Mixpanel sharedInstance] people] set:kMPPushEnabled to:@(NO)];
    DebugLog(@"did fail register for remote notifications");
}

- (BOOL)application:(UIApplication*)application shouldAllowExtensionPointIdentifier:(NSString*)extensionPointIdentifier {
    DebugLog(@"extension? %@", extensionPointIdentifier);
    return YES;
}

#pragma mark - Photo and PDF Import

- (void)importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication {
    if (!sourceApplication)
        sourceApplication = @"app.unknown";
    // need to have a reference to this, because
    // calling url.pathExtension seems to immediately dealloc
    // the path extension when i pass it into the dict below
    [self.viewController importFileFrom:url fromApp:sourceApplication];
    [[Mixpanel sharedInstance] flush];
}


#pragma mark - Session Duration

- (void)logActiveAppDuration {
    if (durationTimer) {
        NSNumber* amount = @((CFAbsoluteTimeGetCurrent() - sessionStartStamp) / 60.0);
        DebugLog(@"duration tick: %@", amount);
        // sanity check, only log time if our timer is running
        [[[Mixpanel sharedInstance] people] increment:kMPDurationAppOpen by:amount];
        sessionStartStamp = CFAbsoluteTimeGetCurrent();
        [[Mixpanel sharedInstance] flush];
    }
}

- (void)stopTimer {
    [durationTimer invalidate];
    durationTimer = nil;
}

- (void)setupTimer {
    sessionStartStamp = CFAbsoluteTimeGetCurrent();
    // track every minute that the app is open
    [self stopTimer];
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                     target:self
                                                   selector:@selector(logActiveAppDuration)
                                                   userInfo:nil
                                                    repeats:YES];
}


#pragma mark - User UUID

+ (NSString*)userID {
    NSString* uuid = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:@"userID"];
    if (!uuid) {
        uuid = [NSString createStringUUID];
        [SSKeychain setPassword:uuid forService:[[NSBundle mainBundle] bundleIdentifier] account:@"userID"];
    }
    return uuid;
}

+ (NSString*)email {
    NSString* email = [[NSUserDefaults standardUserDefaults] stringForKey:kMPEmailAddressField];

    if (!email) {
        email = [[NSUserDefaults standardUserDefaults] stringForKey:kPendingEmailToSubscribe];
    }

    return email;
}

+ (void)setEmail:(NSString*)email {
    if (email) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:kMPEmailAddressField];
        [SSKeychain setPassword:email forService:[[NSBundle mainBundle] bundleIdentifier] account:kMPEmailAddressField];
    }
}

#pragma mark - Track Memory Crash

- (void)trackDidCrashFromMemoryForDate:(NSDate*)dateOfCrash {
    DebugLog(@"Did Track Crash from Memory");
    DebugLog(@"===========================");
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfMemoryCrashes by:@(1)];

    @try {
        NSMutableDictionary* crashProperties = [NSMutableDictionary dictionary];
        [crashProperties setObject:@"Memory" forKey:@"Cause"];
        if ([UIApplication bundleVersion])
            [crashProperties setObject:[UIApplication bundleVersion] forKey:@"bundleVersion"];
        if ([UIApplication bundleShortVersionString])
            [crashProperties setObject:[UIApplication bundleShortVersionString] forKey:@"bundleShortVersionString"];
        if (dateOfCrash)
            [crashProperties setObject:dateOfCrash forKey:@"crashedOnDate"];
        if ([UIDevice majorVersion])
            [crashProperties setObject:@([UIDevice majorVersion]) forKey:@"OSVersion"];
        if ([UIDevice buildVersion])
            [crashProperties setObject:[UIDevice buildVersion] forKey:@"OSBuildVersion"];

        NSMutableDictionary* mappedCrashProperties = [NSMutableDictionary dictionary];
        [crashProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            [mappedCrashProperties setObject:obj forKey:[@"Crash Property: " stringByAppendingString:key]];
        }];

        [[Mixpanel sharedInstance] track:kMPEventCrash properties:mappedCrashProperties];
    } @catch (id e) {
        // noop
    }
    [[Mixpanel sharedInstance] flush];
}


#pragma mark - App Lifecycle Tracking

- (NSDate*)dateOfDeathIfAny {
    NSString* pathOfLifecycleTrackingFile = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"launchDate.data"];
    NSDate* date = [NSKeyedUnarchiver unarchiveObjectWithFile:pathOfLifecycleTrackingFile];
    return date;
}

- (void)saveDateOfLaunch {
    NSString* pathOfLifecycleTrackingFile = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"launchDate.data"];
    [NSKeyedArchiver archiveRootObject:[NSDate date] toFile:pathOfLifecycleTrackingFile];
}

- (void)removeDateOfLaunch {
    NSString* pathOfLifecycleTrackingFile = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"launchDate.data"];
    [[NSFileManager defaultManager] removeItemAtPath:pathOfLifecycleTrackingFile error:nil];
}

#pragma mark - Crashlytics reporting

- (void)crashlyticsDidCrashDuringPreviousExecution {
    didRecieveReportFromCrashlytics = YES;

    DebugLog(@"Did Track Crash from Exception");
    DebugLog(@"==============================");
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCrashes by:@(1)];

    NSMutableDictionary* crashProperties = [NSMutableDictionary dictionary];
    [crashProperties setObject:@"Exception" forKey:@"Cause"];

    // set default values
    if ([UIApplication bundleVersion])
        [crashProperties setObject:[UIApplication bundleVersion] forKey:@"bundleVersion"];
    if ([UIApplication bundleShortVersionString])
        [crashProperties setObject:[UIApplication bundleShortVersionString] forKey:@"bundleShortVersionString"];
    [crashProperties setObject:[NSDate date] forKey:@"crashedOnDate"];
    if ([UIDevice majorVersion])
        [crashProperties setObject:@([UIDevice majorVersion]) forKey:@"OSVersion"];
    if ([UIDevice buildVersion])
        [crashProperties setObject:[UIDevice buildVersion] forKey:@"OSBuildVersion"];

    NSMutableDictionary* mappedCrashProperties = [NSMutableDictionary dictionary];
    [crashProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        [mappedCrashProperties setObject:obj forKey:[@"Crash Property: " stringByAppendingString:key]];
    }];

    @try {
        [[Mixpanel sharedInstance] track:kMPEventCrash properties:mappedCrashProperties];
        [[Mixpanel sharedInstance] flush];
    } @catch (id e) {
        // noop
    }
}

@end
