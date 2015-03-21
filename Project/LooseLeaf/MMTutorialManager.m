//
//  MMTutorialManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialManager.h"
#import "MMStopWatch.h"
#import "Mixpanel.h"
#import "Constants.h"

@implementation MMTutorialManager{
    MMStopWatch* stopwatch;
    BOOL hasFinishedTutorial;
    CGFloat timeSpentInTutorial;
    NSInteger currentTutorialStep;
}

@synthesize hasFinishedTutorial;

#pragma mark - Singleton

static MMTutorialManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        hasFinishedTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:kMPHasFinishedTutorial];
        timeSpentInTutorial = [[NSUserDefaults standardUserDefaults] floatForKey:kMPDurationWatchingTutorial];
        currentTutorialStep = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTutorialStep];
        stopwatch = [[MMStopWatch alloc] initWithDuration:timeSpentInTutorial];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

+(MMTutorialManager*) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMTutorialManager alloc] init];
    });
    return _instance;
}

#pragma mark - Public API

-(BOOL) hasCompletedStep:(NSString*)stepID{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[kCurrentTutorialStep stringByAppendingString:stepID]];
}

-(void) didCompleteStep:(NSString*)stepID{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kCurrentTutorialStep stringByAppendingString:stepID]];
}

-(NSArray*) tutorialSteps{
    return @[@{
                 @"id":@"pen",
                 @"title":@"Draw and Erase",
                 @"video":@"hello.mov"
                 },@{
                 @"id":@"nav",
                 @"title":@"Move Between Pages",
                 @"video":@"space-navigation.mov"
                 },@{
                 @"id":@"ruler",
                 @"title":@"Draw a Curve",
                 @"video":@"ruler-for-curve-2.mov"
                 },@{
                 @"id":@"clip",
                 @"title":@"Draw on your Photos",
                 @"video":@"draw-clip-2-2.mov"
                 }];
}

-(BOOL) isWatchingTutorial{
    return [stopwatch isRunning];
}

-(void) startWatchingTutorial{
    [stopwatch start];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTutorialStartedNotification object:self];
}

-(void) pauseWatchingTutorial{
    timeSpentInTutorial = [stopwatch stop];
    [[[Mixpanel sharedInstance] people] set:kMPDurationWatchingTutorial to:@(timeSpentInTutorial)];
    [[NSUserDefaults standardUserDefaults] setFloat:timeSpentInTutorial forKey:kMPDurationWatchingTutorial];
}

-(void) finishWatchingTutorial{
    [self pauseWatchingTutorial];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMPHasFinishedTutorial];
    [[[Mixpanel sharedInstance] people] set:kMPHasFinishedTutorial to:@(YES)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTutorialClosedNotification object:self];
}


#pragma mark - Notifications

-(void) didEnterBackground{
    [self pauseWatchingTutorial];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
