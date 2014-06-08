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
#import "MMMemoryProfileView.h"
#import "Mixpanel.h"
#import "MMMemoryManager.h"

@implementation MMLooseLeafViewController{
    MMMemoryManager* memoryManager;
}

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
        
        
        memoryManager = [[MMMemoryManager alloc] initWithStack:stackView];
        
        MMMemoryProfileView* memoryProfileView = [[MMMemoryProfileView alloc] initWithFrame:self.view.bounds];
        memoryProfileView.memoryManager = memoryManager;
        memoryProfileView.hidden = YES;
        
        [stackView setMemoryView:memoryProfileView];
        [self.view addSubview:memoryProfileView];
    }
    return self;
}

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication{
    // ask the inbox manager to
    [[MMInboxManager sharedInstace] processInboxItem:url fromApp:(NSString*)sourceApplication];
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


#pragma mark - Crashlytics reporting

-(void) crashlytics:(Crashlytics *)crashlytics didDetectCrashDuringPreviousExecution:(id<CLSCrashReport>)crash{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCrashes by:@(1)];
}

#pragma mark - application state

-(void) willResignActive{
    debug_NSLog(@"telling stack to cancel all gestures");
    [stackView cancelAllGestures];
    [[stackView.visibleStackHolder peekSubview] cancelAllGestures];
}

@end
