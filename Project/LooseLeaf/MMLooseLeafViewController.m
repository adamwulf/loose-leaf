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
#import "TestFlight.h"
#import "MMDebugDrawView.h"
#import "MMInboxManager.h"
#import "Mixpanel.h"

@implementation MMLooseLeafViewController

- (id)init{
    if(self = [super init]){
        
//        [NSThread performBlockInBackground:^{
//            [TestFlight takeOff:kTestflightAppToken];
//            [TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogOnCheckpoint : @NO }];
//            [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
//        }];

        [[Crashlytics sharedInstance] setDelegate:self];

        // Do any additional setup after loading the view, typically from a nib.
        srand ((uint) time(NULL) );
        [[MMShadowManager sharedInstace] beginGeneratingShadows];
    
        self.view.opaque = YES;
        
        stackView = [[MMScrapPaperStackView alloc] initWithFrame:self.view.frame];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:stackView];
        
        [stackView loadStacksFromDisk];
        
        [[[Mixpanel sharedInstance] people] set:kMPNumberOfPages
                                             to:@([stackView.visibleStackHolder.subviews count] + [stackView.hiddenStackHolder.subviews count])];
        [[[Mixpanel sharedInstance] people] setOnce:@{kMPFirstLaunchDate : [NSDate date],
                                                      kMPHasAddedPage : @(NO),
                                                      kMPHasZoomedToList : @(NO),
                                                      kMPNumberOfPenUses : @(0),
                                                      kMPNumberOfEraserUses : @(0),
                                                      kMPNumberOfScissorUses : @(0),
                                                      kMPNumberOfRulerUses : @(0),
                                                      kMPNumberOfPhotoImports : @(0),
                                                      kMPNumberOfPhotosTaken : @(0),
                                                      kMPNumberOfExports : @(0),
                                                      kMPDurationAppOpen : @(0.0),
                                                      kMPNumberOfCrashes : @(0),
                                                      kMPDistanceDrawn : @(0.0),
                                                      kMPDistanceErased : @(0.0)}];


        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackblur.png"]]];
        
//        [self.view addSubview:[MMDebugDrawView sharedInstace]];
        
    }
    return self;
}

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication{
    // ask the inbox manager to
    [[MMInboxManager sharedInstace] processInboxItem:url fromApp:(NSString*)sourceApplication];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}


#pragma mark - Crashlytics reporting

-(void) crashlytics:(Crashlytics *)crashlytics didDetectCrashDuringPreviousExecution:(id<CLSCrashReport>)crash{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCrashes by:@(1)];
}


@end
