//
//  MMTutorialStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialStackView.h"
#import "MMTutorialView.h"
#import "MMStopWatch.h"
#import "Mixpanel.h"

@implementation MMTutorialStackView{
    UIView* backdrop;
    MMTutorialView* tutorialView;
    MMTextButton* helpButton;
    MMStopWatch* stopwatch;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        BOOL hasFinishedTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:kMPHasFinishedTutorial];
        CGFloat timeSpentInTutorial = [[NSUserDefaults standardUserDefaults] floatForKey:kMPDurationWatchingTutorial];

        stopwatch = [[MMStopWatch alloc] initWithDuration:timeSpentInTutorial];

        helpButton = [[MMTextButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2 - 2*60, kWidthOfSidebarButton, kWidthOfSidebarButton) andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:24] andLetter:@"?" andXOffset:0 andYOffset:0];
        helpButton.inverted = YES;
        helpButton.delegate = self;
        [helpButton addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
        buttons[numberOfButtons].button = (__bridge void *)(helpButton);
        buttons[numberOfButtons].originalRect = helpButton.frame;
        numberOfButtons++;
        
        if(!hasFinishedTutorial){
            [self startTutorial];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark - Notifications

-(void) didEnterBackground{
    [self stopTheWatch];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Restart Tutorial

-(BOOL) isShowingTutorial{
    return tutorialView != nil;
}

-(void) startTutorial{
    if([self isShowingTutorial]){
        return;
    }
    [stopwatch start];
    backdrop = [[UIView alloc] initWithFrame:self.bounds];
    backdrop.backgroundColor = [UIColor whiteColor];
    backdrop.alpha = 0;
    [self addSubview:backdrop];
    
    tutorialView = [[MMTutorialView alloc] initWithFrame:self.bounds];
    tutorialView.delegate = self;
    tutorialView.alpha = 0;
    [self addSubview:tutorialView];
    
    [UIView animateWithDuration:.3 animations:^{
        backdrop.alpha = 1;
        tutorialView.alpha = 1;
    }];
}

#pragma mark - MMTutorialViewDelegate

-(void) userIsViewingTutorialStep:(NSInteger)stepNum{
    NSLog(@"user is watching %d", (int) stepNum);
    
    
}

-(void) stopTheWatch{
    CGFloat timeSpentInTutorial = [stopwatch stop];
    [[[Mixpanel sharedInstance] people] set:kMPDurationWatchingTutorial to:@(timeSpentInTutorial)];
    [[NSUserDefaults standardUserDefaults] setFloat:timeSpentInTutorial forKey:kMPDurationWatchingTutorial];
}

-(void) didFinishTutorial{
    if(![stopwatch isRunning]){
        return;
    }
    [self stopTheWatch];
    [UIView animateWithDuration:.3 animations:^{
        backdrop.alpha = 0;
        tutorialView.alpha = 0;
    } completion:^(BOOL finished) {
        [backdrop removeFromSuperview];
        backdrop = nil;
        [tutorialView removeFromSuperview];
        tutorialView = nil;
        [self performSelector:@selector(bounceSidebarButton:) withObject:helpButton afterDelay:.3];
    }];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMPHasFinishedTutorial];
    [[[Mixpanel sharedInstance] people] set:kMPHasFinishedTutorial to:@(YES)];
}

@end
