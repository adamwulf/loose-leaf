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
#import "MMTutorialManager.h"

@implementation MMTutorialStackView{
    UIView* backdrop;
    MMTutorialView* tutorialView;
    MMTextButton* helpButton;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        helpButton = [[MMTextButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2 - 2*60, kWidthOfSidebarButton, kWidthOfSidebarButton) andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:24] andLetter:@"?" andXOffset:0 andYOffset:0];
        helpButton.inverted = YES;
        helpButton.delegate = self;
        [helpButton addTarget:[MMTutorialManager sharedInstance] action:@selector(startWatchingTutorial) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
        buttons[numberOfButtons].button = (__bridge void *)(helpButton);
        buttons[numberOfButtons].originalRect = helpButton.frame;
        numberOfButtons++;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialShouldOpen:) name:kTutorialStartedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialShouldClose:) name:kTutorialClosedNotification object:nil];
        
        if(![[MMTutorialManager sharedInstance] hasFinishedTutorial]){
            [[MMTutorialManager sharedInstance] startWatchingTutorial];
        }
    }
    return self;
}


#pragma mark - Private Helpers

-(BOOL) isShowingTutorial{
    return tutorialView != nil || tutorialView.alpha;
}

#pragma mark - Tutorial Notifications

-(void) tutorialShouldOpen:(NSNotification*)note{
    if([self isShowingTutorial]){
        // tutorial is already showing, just return
        return;
    }
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

-(void) tutorialShouldClose:(NSNotification*)note{
    if(![self isShowingTutorial]){
        // tutorial is already hidden, just return
        return;
    }
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
}


#pragma mark - MMTutorialViewDelegate

-(void) userIsViewingTutorialStep:(NSInteger)stepNum{
    NSLog(@"user is watching %d", (int) stepNum);
}

-(void) didFinishTutorial{
    [self tutorialShouldClose:nil];
}

@end
