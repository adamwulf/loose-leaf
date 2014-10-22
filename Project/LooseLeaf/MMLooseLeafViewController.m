//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMLooseLeafViewController.h"
#import "MMShadowManager.h"
#import "MMEditablePaperView.h"
#import "MMDebugDrawView.h"
#import "MMInboxManager.h"
#import "MMMemoryProfileView.h"
#import "Mixpanel.h"
#import "MMMemoryManager.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMDeletePageSidebarController.h"
#import "MMPhotoManager.h"
#import "MMCloudKitImportExportView.h"

@implementation MMLooseLeafViewController{
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;
    MMCloudKitImportExportView* cloudKitExportView;
}

- (id)init{
    if(self = [super init]){
#ifdef DEBUG
//        NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
//        [[NSUserDefaults standardUserDefaults] synchronize];
#endif
        
        
        [[Crashlytics sharedInstance] setDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pageCacheManagerDidLoadPage)
                                                     name:kPageCacheManagerHasLoadedAnyPage
                                                   object:[MMPageCacheManager sharedInstance]];

        // Do any additional setup after loading the view, typically from a nib.
        srand ((uint) time(NULL) );
        [[MMShadowManager sharedInstance] beginGeneratingShadows];
    
        self.view.opaque = YES;
        
        deleteSidebar = [[MMDeletePageSidebarController alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:deleteSidebar.deleteSidebarBackground];
        
        stackView = [[MMScrapPaperStackView alloc] initWithFrame:self.view.bounds];
//        stackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        stackView.deleteSidebar = deleteSidebar;
        [self.view addSubview:stackView];
        stackView.center = self.view.center;

        // export icons will show here, below the sidebars but over the stacks
        cloudKitExportView = [[MMCloudKitImportExportView alloc] initWithFrame:self.view.bounds];
        stackView.cloudKitExportView = cloudKitExportView;
        cloudKitExportView.stackView = stackView;
        [self.view addSubview:cloudKitExportView];
        // an extra view to help with animations
        MMUntouchableView* exportAnimationHelperView = [[MMUntouchableView alloc] initWithFrame:self.view.bounds];
        cloudKitExportView.animationHelperView = exportAnimationHelperView;
        [self.view addSubview:exportAnimationHelperView];
        
        [self.view addSubview:deleteSidebar.deleteSidebarForeground];

        [stackView loadStacksFromDisk];
        
        [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:stackView];
        
        [[[Mixpanel sharedInstance] people] set:kMPNumberOfPages
                                             to:@([stackView.visibleStackHolder.subviews count] + [stackView.hiddenStackHolder.subviews count])];
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[[Mixpanel sharedInstance] people] set:kMPPreferredLanguage
                                             to:language];
        [[[Mixpanel sharedInstance] people] setOnce:@{kMPFirstLaunchDate : [NSDate date],
                                                      kMPHasAddedPage : @(NO),
                                                      kMPHasZoomedToList : @(NO),
                                                      kMPNumberOfPenUses : @(0),
                                                      kMPNumberOfEraserUses : @(0),
                                                      kMPNumberOfScissorUses : @(0),
                                                      kMPNumberOfRulerUses : @(0),
                                                      kMPNumberOfImports : @(0),
                                                      kMPNumberOfPhotoImports : @(0),
                                                      kMPNumberOfCloudKitImports : @(0),
                                                      kMPNumberOfPhotosTaken : @(0),
                                                      kMPNumberOfExports : @(0),
                                                      kMPNumberOfCloudKitExports : @(0),
                                                      kMPDurationAppOpen : @(0.0),
                                                      kMPNumberOfCrashes : @(0),
                                                      kMPDistanceDrawn : @(0.0),
                                                      kMPDistanceErased : @(0.0),
                                                      kMPNumberOfClippingExceptions : @(0.0),
                                                      kMPShareStatusFacebook : kMPShareStatusUnknown,
                                                      kMPShareStatusTwitter : kMPShareStatusUnknown,
                                                      kMPShareStatusEmail : kMPShareStatusUnknown,
                                                      kMPShareStatusSMS : kMPShareStatusUnknown,
                                                      kMPShareStatusTencentWeibo : kMPShareStatusUnknown,
                                                      kMPShareStatusSinaWeibo : kMPShareStatusUnknown,
                                                      }];

        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackblur.png"]]];
        
//        [self.view addSubview:[MMDebugDrawView sharedInstance]];
        
        
        memoryManager = [[MMMemoryManager alloc] initWithStack:stackView];
        
//        MMMemoryProfileView* memoryProfileView = [[MMMemoryProfileView alloc] initWithFrame:self.view.bounds];
//        memoryProfileView.memoryManager = memoryManager;
//        memoryProfileView.hidden = YES;
//        
//        [stackView setMemoryView:memoryProfileView];
//        [self.view addSubview:memoryProfileView];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    
}

-(void) pageCacheManagerDidLoadPage{
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPageCacheManagerHasLoadedAnyPage object:nil];
}

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication{
    // ask the inbox manager to
    [[MMInboxManager sharedInstance] processInboxItem:url fromApp:(NSString*)sourceApplication];
}

-(void) printKeys:(NSDictionary*)dict atlevel:(NSInteger)level{
    NSString* space = @"";
    for(int i=0;i<level;i++){
        space = [space stringByAppendingString:@" "];
    }
    for(NSString* key in [dict allKeys]){
        
        id obj = [dict objectForKey:key];
        if([obj isKindOfClass:[NSDictionary class]]){
            [self printKeys:obj atlevel:level+1];
        }else{
            if([obj isKindOfClass:[NSArray class]]){
                debug_NSLog(@"%@ %@ - %@ [%lu]", space, key, [obj class], (unsigned long)[obj count]);
            }else{
                debug_NSLog(@"%@ %@ - %@", space, key, [obj class]);
            }
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL) shouldAutorotate{
    return NO;
}


#pragma mark - Crashlytics reporting

-(void) crashlytics:(Crashlytics *)crashlytics didDetectCrashDuringPreviousExecution:(id<CLSCrashReport>)crash{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCrashes by:@(1)];
    
    NSMutableDictionary* crashProperties = [NSMutableDictionary dictionary];
    if(crash.customKeys) [crashProperties addEntriesFromDictionary:crash.customKeys];
    if(crash.identifier) [crashProperties setObject:crash.identifier forKey:@"identifier"];
    if(crash.bundleVersion) [crashProperties setObject:crash.bundleVersion forKey:@"bundleVersion"];
    if(crash.bundleShortVersionString) [crashProperties setObject:crash.bundleShortVersionString forKey:@"bundleShortVersionString"];
    if(crash.crashedOnDate) [crashProperties setObject:crash.crashedOnDate forKey:@"crashedOnDate"];
    if(crash.OSVersion) [crashProperties setObject:crash.OSVersion forKey:@"OSVersion"];
    if(crash.OSBuildVersion) [crashProperties setObject:crash.OSBuildVersion forKey:@"OSBuildVersion"];
    
    NSMutableDictionary* mappedCrashProperties = [NSMutableDictionary dictionary];
    [crashProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [mappedCrashProperties setObject:obj forKey:[@"Crashlytics: " stringByAppendingString:key]];
    }];
    
    @try{
        [[Mixpanel sharedInstance] track:kMPEventCrash properties:mappedCrashProperties];
    }@catch(id e){
        // noop
    }

}

#pragma mark - application state

-(void) willResignActive{
    debug_NSLog(@"telling stack to cancel all gestures");
    [stackView cancelAllGestures];
    [[stackView.visibleStackHolder peekSubview] cancelAllGestures];
}


-(void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:flag completion:completion];
//    NSLog(@"dismissing view controller");
}

-(void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
//    NSLog(@"presenting view controller");
}

@end
