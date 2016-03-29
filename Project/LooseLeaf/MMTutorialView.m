//
//  MMTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialView.h"
#import "MMVideoLoopView.h"
#import "MMImageLoopView.h"
#import "MMTutorialManager.h"
#import "MMRotationManager.h"
#import "AVHexColor.h"
#import "MMTutorialButton.h"
#import "MMNewsletterSignupForm.h"
#import "MMCheckButton.h"
#import "MMNewsletterSignupFormDelegate.h"
#import "MMUntouchableTutorialView.h"
#import "UIColor+Shadow.h"
#import "NSArray+Extras.h"
#import "Constants.h"
#import "NSURL+UTI.h"
#import "Mixpanel.h"
#import "NSArray+MapReduce.h"

@interface MMTutorialView ()<MMNewsletterSignupFormDelegate>

@end

@implementation MMTutorialView{
    
    NSMutableArray* tutorialButtons;
    
    UIView* fadedBackground;
    UIScrollView* scrollView;
    UIView* separator;
    UIButton* nextButton;
    
    __weak NSObject<MMTutorialViewDelegate>* delegate;
    
    MMNewsletterSignupForm* newsletterSignupForm;
    
    NSArray* tutorialList;
}

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame andTutorials:(NSArray*)_tutorialList{
    if(self = [super initWithFrame:frame]){
        
        tutorialList = _tutorialList;
        
        // 10% buffer
        CGFloat boxSize = 600;
        CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;

        //
        // scrollview
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
        scrollView.delaysContentTouches = NO;
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialViewWasTapped:)];
        [scrollView addGestureRecognizer:tapGesture];
        
        [self.maskedScrollContainer addSubview:scrollView];
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, 1, boxSize)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self.maskedScrollContainer addSubview:separator];

        CGFloat buttonWidth = 160;
        CGFloat buttonHeight = 70;
        CGFloat adjust = .35;
        nextButton = [[UIButton alloc] initWithFrame:CGRectMake(boxSize-buttonWidth, boxSize-buttonHeight, buttonWidth, buttonHeight*(1+adjust))];
        nextButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, adjust*buttonHeight, 0);
        nextButton.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        nextButton.adjustsImageWhenHighlighted = NO;
        [nextButton setImage:[UIImage imageNamed:@"white-arrow.png"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];

        CAShapeLayer* nextButtonMask = [CAShapeLayer layer];
        nextButtonMask.backgroundColor = [UIColor clearColor].CGColor;
        nextButtonMask.fillColor = [UIColor whiteColor].CGColor;
        nextButtonMask.path = [UIBezierPath bezierPathWithRoundedRect:nextButton.bounds
                                                    byRoundingCorners:UIRectCornerTopLeft
                                                          cornerRadii:CGSizeMake(boxSize/10, boxSize/10)].CGPath;
        nextButton.layer.mask = nextButtonMask;
        
        [self.maskedScrollContainer addSubview:nextButton];
        
        self.rotateableSquareView.transform = CGAffineTransformMakeRotation([self interfaceRotationAngle]);

        [self loadTutorials];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialStepFinished:) name:kTutorialStepCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setDelegate:(NSObject<MMTutorialViewDelegate> *)_delegate{
    delegate = _delegate;
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self.delegate userIsViewingTutorialStep:idx];
}

-(void) tapToClose{
    [self didTapToChangeToTutorial:[tutorialButtons lastObject]];
}

#pragma mark - Notifications

-(void) tutorialViewWasTapped:(id)sender{
    NSLog(@"tapped");
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    idx = MAX(0, MIN(idx, [tutorialList count] - 1));
    
    if([[tutorialList objectAtIndex:idx] objectForKey:@"hide-buttons"]){
        [self didTapToChangeToTutorial:[tutorialButtons firstObject]];
    }
}

-(void) tutorialStepFinished:(NSNotification*)note{
    NSString* tutorialId = note.object;
    NSArray* tutorials = tutorialList;
    NSUInteger index = [tutorials indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"id"] isEqualToString:tutorialId];
    }];
    if(index == NSNotFound){
        return;
    }
    
    MMLoopView* tutorialView = [scrollView.subviews objectAtIndex:index];
    
    index = [[tutorialButtons reduce:^id(id obj, NSUInteger buttonIndex, id accum) {
        if([obj tag] == index){
            return @(buttonIndex);
        }
        return accum;
    }] unsignedIntegerValue];
    
    [[tutorialButtons objectAtIndex:index] setFinished:YES];
    [[tutorialButtons objectAtIndex:index] bounceButton];
    
    
    if([tutorialView wantsNextButton] && [tutorialView wantsHiddenButtons]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint targetCenter = nextButton.center;
            nextButton.center = CGPointMake(targetCenter.x, targetCenter.y + 20);
            [UIView animateWithDuration:.2 animations:^{
                nextButton.alpha = 1;
                nextButton.center = CGPointMake(targetCenter.x, targetCenter.y - 8);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.15 animations:^{
                    nextButton.center = CGPointMake(targetCenter.x, targetCenter.y);
                }];
            }];
        });
    }
}

-(MMTutorialButton*) tutorialButtonForTutorialAtIndex:(NSInteger)tutorialIndex{
    
    if(tutorialIndex >= [tutorialList count]){
        return [tutorialButtons lastObject];
    }

    __block NSInteger actualTutorialIndex = -1;
    [tutorialList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(![[obj objectForKey:@"hide-buttons"] boolValue]){
            actualTutorialIndex += 1;
        }
        if(idx == tutorialIndex){
            *stop = YES;
        }
    }];
    
    if(actualTutorialIndex >= 0 && actualTutorialIndex < [tutorialButtons count]){
        return [tutorialButtons objectAtIndex:actualTutorialIndex];
    }
    return [tutorialButtons lastObject];
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    
    UIButton* button = [self tutorialButtonForTutorialAtIndex:idx];
    button.selected = YES;
    [[tutorialButtons arrayByRemovingObject:button] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setSelected:NO];
    }];
    
    
    int location = scrollView.bounds.size.width - (int)scrollView.contentOffset.x % (int)scrollView.bounds.size.width;
    CGRect fr = separator.frame;
    fr.origin.x = scrollView.contentOffset.x < 0 ? ABS(scrollView.contentOffset.x) : location;
    separator.frame = fr;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)_scrollView{
    // as the user is dragging and scrolling the tutorial view,
    // just don't animate any tutorials
    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj respondsToSelector:@selector(pauseAnimating)]){
            [obj pauseAnimating];
        }
    }];
}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)_scrollView{
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    MMVideoLoopView* visible = [scrollView.subviews objectAtIndex:idx];
    if(![visible isBuffered]){
        // a different view was animating, but we just
        // started showing a new tutorial. tell
        // all the others to stop animating
        [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj respondsToSelector:@selector(stopAnimating)]){
                [obj stopAnimating];
            }
        }];
    }
    if([visible respondsToSelector:@selector(startAnimating)]){
        // ok, now tell us to start animating
        [visible startAnimating];
    }
    [UIView animateWithDuration:.3 animations:^{
        nextButton.alpha = [visible wantsNextButton] ? 1 : 0;
        [tutorialButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setAlpha:[visible wantsHiddenButtons] ? 0 : 1];
        }];
    }];
    if(idx < [tutorialList count]){
        // notify, but only if its a proper tutorial
        [self.delegate userIsViewingTutorialStep:idx];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)_scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}


#pragma mark - Tutorial Loading


-(void) unloadTutorials{
    for(UIView* tutorialView in scrollView.subviews){
        if([tutorialView respondsToSelector:@selector(stopAnimating)]){
            [tutorialView performSelector:@selector(stopAnimating)];
        }
    }
}

-(void) loadTutorials{
    NSArray* tutorials = tutorialList;
    __block NSInteger numberOfTutorialButtons = 0;
    
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* videoURL = [obj objectForKey:@"video"];
        NSString* videoTitle = [obj objectForKey:@"title"];
        NSString* videoId = [obj objectForKey:@"id"];
        NSURL* tutorialURL = [[NSBundle mainBundle] URLForResource:videoURL withExtension:nil];
        MMLoopView* tutorialView = nil;
        if([MMVideoLoopView supportsURL:tutorialURL]){
            MMVideoLoopView* videoView = [[MMVideoLoopView alloc] initForVideo:tutorialURL withTitle:videoTitle forTutorialId:videoId];
            [scrollView addSubview:videoView];
            tutorialView = videoView;
        }else if([MMImageLoopView supportsURL:tutorialURL]){
            MMImageLoopView* imgView = [[MMImageLoopView alloc] initForImage:tutorialURL withTitle:videoTitle forTutorialId:videoId];
            [scrollView addSubview:imgView];
            tutorialView = imgView;
        }else{
            NSLog(@"failed: %@", tutorialURL);
        }
        tutorialView.wantsHiddenButtons = [[obj objectForKey:@"hide-buttons"] boolValue];
        
        numberOfTutorialButtons += !tutorialView.wantsHiddenButtons;
        
        CGRect fr = scrollView.bounds;
        fr.origin.x = idx * fr.size.width;
        tutorialView.frame = fr;
        [tutorialView stopAnimating];
    }];
    
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * [tutorials count], scrollView.bounds.size.height);

    if(![[MMTutorialManager sharedInstance] hasSignedUpForNewsletter]){
        // add the newsletter form
        newsletterSignupForm = [[MMNewsletterSignupForm alloc] initForm];
        newsletterSignupForm.delegate = self;
        CGRect fr = scrollView.bounds;
        fr.origin.x = [tutorials count] * fr.size.width;
        newsletterSignupForm.frame = fr;
        [scrollView addSubview:newsletterSignupForm];

        // add width for the newsletter signup
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + scrollView.bounds.size.width, scrollView.contentSize.height);
    }
    
    MMLoopView* firstTutorialView = scrollView.subviews.firstObject;
    
    [firstTutorialView startAnimating];
    
    CGFloat widthForButtonCenters = self.rotateableSquareView.bounds.size.width;
    CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;
    widthForButtonCenters = widthForButtonCenters - 2 * buttonBuffer;
    widthForButtonCenters = widthForButtonCenters - kWidthOfSidebarButton;
    widthForButtonCenters -= 100;
    CGFloat stepForEachButton = widthForButtonCenters / numberOfTutorialButtons;
    CGFloat startX = (self.rotateableSquareView.bounds.size.width - widthForButtonCenters) / 2;
    
    tutorialButtons = [NSMutableArray array];
    __block NSInteger buttonIndex = 0;
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* tutorial = [tutorials objectAtIndex:idx];
        if(![[obj objectForKey:@"hide-buttons"] boolValue]){
            MMTutorialButton* button = [[MMTutorialButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)
                                                                 forStepNumber:buttonIndex+1];
            button.tag = idx;
            button.finished = [[MMTutorialManager sharedInstance] hasCompletedStep:[tutorial objectForKey:@"id"]];
            CGPoint center = CGPointMake(startX + stepForEachButton * buttonIndex, kWidthOfSidebarButton / 2 + kWidthOfSidebarButtonBuffer);
            button.center = center;
            
            if(buttonIndex == 0){
                button.selected = YES;
            }
            
            [button addTarget:self action:@selector(didTapToChangeToTutorial:) forControlEvents:UIControlEventTouchUpInside];
            
            [tutorialButtons addObject:button];
            [self.rotateableSquareView addSubview:button];
            buttonIndex += 1;
        }
    }];
    
    MMCheckButton* checkButton = [[MMCheckButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    CGPoint center = CGPointMake(startX + widthForButtonCenters, kWidthOfSidebarButton / 2 + kWidthOfSidebarButtonBuffer);
    checkButton.center = center;
    checkButton.tag = NSIntegerMax;
    [tutorialButtons addObject:checkButton];
    [self.rotateableSquareView addSubview:checkButton];
    [checkButton addTarget:self action:@selector(didTapToChangeToTutorial:) forControlEvents:UIControlEventTouchUpInside];
    
    
    nextButton.alpha = [firstTutorialView wantsNextButton] && ![firstTutorialView wantsHiddenButtons] ? 1 : 0;
    [tutorialButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:[firstTutorialView wantsHiddenButtons] ? 0 : 1];
    }];

}


#pragma mark - Rotation

-(CGFloat) interfaceRotationAngle{
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [newsletterSignupForm didRotateToIdealOrientation:orientation];
    });
}

#pragma mark - Button Helpers

-(void) nextPressed:(UIButton*)_button{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    if(idx == [scrollView.subviews count]-1){
        // they're already on the last step,
        // and are finishing the tutorial
        [self didTapToChangeToTutorial:[tutorialButtons lastObject]];
        return;
    }
    idx = MIN(idx+1, [scrollView.subviews count]-1);
    CGFloat x = idx*scrollView.bounds.size.width;
    [scrollView scrollRectToVisible:CGRectMake(x, 0, scrollView.bounds.size.width, scrollView.bounds.size.height) animated:YES];
}

-(void) didTapToChangeToTutorial:(MMTutorialButton*)button{
    NSInteger tutorialIndex = button.tag;
    if(tutorialIndex == NSIntegerMax){
        // end the tutorial
        if(newsletterSignupForm){
            [scrollView scrollRectToVisible:newsletterSignupForm.frame animated:YES];
        }else{
            [self.delegate didFinishTutorial];
        }
        return;
    }
    CGRect squareOfTutorial = CGRectMake(tutorialIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    [scrollView scrollRectToVisible:squareOfTutorial animated:YES];
}

#pragma mark - MMNewsletterSignupFormDelegate

-(void) didCompleteNewsletterStep{
    [self.delegate didFinishTutorial];
}


#pragma mark - Private Helpers

-(CGPoint) topLeftCornerForBoxSize:(CGFloat)width{
    return CGPointMake((self.bounds.size.width - width) / 2, (self.bounds.size.height - width) / 2);
}

-(UIBezierPath*) roundedRectPathForBoxSize:(CGFloat)width withOrigin:(CGPoint)boxOrigin{
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(boxOrigin.x, boxOrigin.y, width, width)
                          byRoundingCorners:UIRectCornerAllCorners
                                cornerRadii:CGSizeMake(width/10, width/10)];
}

-(void) didEnterBackground{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    
    if(idx < [tutorialList count]){
        NSString* tutorialId = [[tutorialList objectAtIndex:idx] objectForKey:@"id"];
        if(tutorialId){
            [[Mixpanel sharedInstance] track:kMPBackgroundDuringTutorial properties:@{@"Tutorial" : tutorialId}];
        }else{
            [[Mixpanel sharedInstance] track:kMPBackgroundDuringTutorial properties:@{@"Tutorial" : @"unknown"}];
        }
    }else{
        [[Mixpanel sharedInstance] track:kMPBackgroundDuringTutorial properties:@{@"Tutorial" : @"newsletter"}];
    }
    
    [[[Mixpanel sharedInstance] people] set:kMPDidBackgroundDuringTutorial to:@(YES)];
    [[Mixpanel sharedInstance] flush];
}

@end
