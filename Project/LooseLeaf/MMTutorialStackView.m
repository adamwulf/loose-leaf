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
#import "MMTutorialSidebarButton.h"
#import "Mixpanel.h"
#import "MMTutorialManager.h"
#import "MMLargeTutorialSidebarButton.h"

@implementation MMTutorialStackView{
    UIView* backdrop;
    MMTutorialView* tutorialView;
    MMTextButton* helpButton;
    MMLargeTutorialSidebarButton* listViewTutorialButton;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString *)_uuid{
    if(self = [super initWithFrame:frame andUUID:_uuid]){
        helpButton = [[MMTutorialSidebarButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton) andTutorialList:^NSArray *{
            return [[MMTutorialManager sharedInstance] appHelpButtonTutorialSteps];
        }];
        helpButton.delegate = self;
        [helpButton addTarget:self action:@selector(tutorialButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:helpButton extendFrame:NO];
        
        if(![[MMTutorialManager sharedInstance] hasFinishedTutorial]){
            [[MMTutorialManager sharedInstance] startWatchingTutorials:[[MMTutorialManager sharedInstance] appIntroTutorialSteps]];
        }
        
        CGRect typicalBounds = CGRectMake(0, 0, 80, 80);
        listViewTutorialButton = [[MMLargeTutorialSidebarButton alloc] initWithFrame:typicalBounds andTutorialList:^NSArray *{
            return [[MMTutorialManager sharedInstance] listViewTutorialSteps];
        }];
        listViewTutorialButton.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 100);
        [listViewTutorialButton addTarget:self action:@selector(tutorialButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self moveAddButtonToBottom];
    }
    return self;
}

#pragma mark - Tutorial Buttons

-(void) tutorialButtonPressed:(MMTutorialSidebarButton*)tutorialButton{
    [[MMTutorialManager sharedInstance] startWatchingTutorials:tutorialButton.tutorialList];
}


#pragma mark - Tutorial Notifications

-(void) tutorialShouldOpen:(NSNotification*)note{
    [super tutorialShouldOpen:note];
    
    self.scrollEnabled = NO;
    [self disableAllGesturesForPageView];
}

-(void) tutorialShouldClose:(NSNotification*)note{
    [super tutorialShouldClose:note];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger numPendingTutorials = [[MMTutorialManager sharedInstance] numberOfPendingTutorials:[[MMTutorialManager sharedInstance] appHelpButtonTutorialSteps]];
        if(numPendingTutorials){
            [self performSelector:@selector(bounceSidebarButton:) withObject:helpButton afterDelay:.3];
        }
    });
    
    if(!self.isShowingPageView){
        self.scrollEnabled = YES;
    }else{
        [self enableAllGesturesForPageView];
    }
}

#pragma mark - Rotation Manager Delegate

-(void) didUpdateAccelerometerWithReading:(MMVector*)currentRawReading{
    [NSThread performBlockOnMainThread:^{
        CGFloat rotationValue = [self sidebarButtonRotation];
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotationValue);
        addPageSidebarButton.transform = rotationTransform;
        helpButton.transform = rotationTransform;
        helpButton.rotation = rotationValue;

        // this'll let super's call run entirely on the main thread,
        // instead both us + them adding blocks to the main thread's
        // queue
        [super didUpdateAccelerometerWithReading:currentRawReading];
    }];
}

-(CGFloat) listViewButtonRotation{
    if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait){
        return 0;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft){
        return -M_PI_2;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight){
        return M_PI_2;
    }else{
        return M_PI;
    }
}

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)orientation{
    [super didRotateToIdealOrientation:orientation];
    [tutorialView didRotateToIdealOrientation:orientation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self listViewButtonRotation]);
            listViewTutorialButton.rotation = [self sidebarButtonRotation];
            listViewTutorialButton.transform = rotationTransform;
        }];
    });
}

#pragma mark - List View Tutorial

-(CGFloat) contentHeightForAllPages{
    return [super contentHeightForAllPages] + 140;
}

-(CGPoint) locationForTutorialButtonInListView{
    return CGPointMake(self.bounds.size.width/2, [self contentHeightForAllPages] - 110);;
}

-(void) subclassBeforeTransitionToListView{
    [super subclassBeforeTransitionToListView];

    listViewTutorialButton.center = [self locationForTutorialButtonInListView];
    CGRect fr = listViewTutorialButton.frame;
    fr.origin.y -= initialScrollOffsetFromTransitionToListView.y;
    listViewTutorialButton.frame = fr;
    listViewTutorialButton.alpha = 0;
}

-(void) subclassDuringTransitionToListView{
    [super subclassDuringTransitionToListView];
    listViewTutorialButton.alpha = 1;
}


-(void) moveAddButtonToBottom{
    [super moveAddButtonToBottom];
    [self insertSubview:listViewTutorialButton atIndex:0];
    listViewTutorialButton.alpha = 0;
}

-(void) moveAddButtonToTop{
    [super moveAddButtonToTop];
    [self addSubview:listViewTutorialButton];
    listViewTutorialButton.alpha = 1;
    
    listViewTutorialButton.center = [self locationForTutorialButtonInListView];
}

#pragma mark - tap control

-(BOOL) shouldPrioritizeSidebarButtonsForTaps{
    if([self.stackDelegate isShowingTutorial]){
        return NO;
    }
    return [super shouldPrioritizeSidebarButtonsForTaps];
}

@end
