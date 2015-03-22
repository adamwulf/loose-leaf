//
//  MMTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialView.h"
#import "MMVideoLoopView.h"
#import "MMTutorialManager.h"
#import "MMRotationManager.h"
#import "AVHexColor.h"
#import "MMTutorialButton.h"
#import "MMCheckButton.h"
#import "UIColor+Shadow.h"
#import "NSArray+Extras.h"
#import "Constants.h"

@implementation MMTutorialView{
    
    UIView* rotateableTutorialSquare;
    NSMutableArray* tutorialButtons;
    
    UIPageControl* pageControl;
    UIView* fadedBackground;
    UIScrollView* scrollView;
    UIView* separator;
    UIButton* nextButton;
    
    __weak NSObject<MMTutorialViewDelegate>* delegate;
}

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // 10% buffer
        CGFloat boxSize = 600;
        CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;
        
        //
        // faded background
        
        fadedBackground = [[UIView alloc] initWithFrame:self.bounds];
        fadedBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        
        [self addSubview:fadedBackground];
        
        
        CGFloat widthOfRotateableContainer = boxSize + 2 * buttonBuffer;
        rotateableTutorialSquare = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - widthOfRotateableContainer) / 2,
                                                                            (self.bounds.size.height - widthOfRotateableContainer) / 2,
                                                                            widthOfRotateableContainer,
                                                                            widthOfRotateableContainer)];
        [self addSubview:rotateableTutorialSquare];
        
        
        //
        // scrollview
        
        CGPoint boxOrigin = CGPointMake(buttonBuffer, buttonBuffer);
        UIView* maskedScrollContainer = [[UIView alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y, boxSize, boxSize)];
        
        CAShapeLayer* scrollMaskLayer = [CAShapeLayer layer];
        scrollMaskLayer.backgroundColor = [UIColor clearColor].CGColor;
        scrollMaskLayer.fillColor = [UIColor whiteColor].CGColor;
        scrollMaskLayer.path = [self roundedRectPathForBoxSize:boxSize withOrigin:CGPointZero].CGPath;
        maskedScrollContainer.layer.mask = scrollMaskLayer;

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
        
        [maskedScrollContainer addSubview:scrollView];
        [rotateableTutorialSquare addSubview:maskedScrollContainer];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y + boxSize-40, boxSize, 40)];
        pageControl.pageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
        pageControl.userInteractionEnabled = NO;
        pageControl.currentPageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        [rotateableTutorialSquare addSubview:pageControl];

        
        separator = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, 1, boxSize)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [maskedScrollContainer addSubview:separator];

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
        
        [maskedScrollContainer addSubview:nextButton];
        
        rotateableTutorialSquare.transform = CGAffineTransformMakeRotation([self interfaceRotationAngle]);

        [self loadTutorials];
    }
    return self;
}

-(void) setDelegate:(NSObject<MMTutorialViewDelegate> *)_delegate{
    delegate = _delegate;
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self.delegate userIsViewingTutorialStep:idx];
}

#pragma mark - Actions

-(void) nextPressed:(UIButton*)_button{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    if(idx == [scrollView.subviews count]-1){
        // they're already on the last step,
        // and are finishing the tutorial
        [self.delegate didFinishTutorial];
    }
    idx = MIN(idx+1, [scrollView.subviews count]-1);
    CGFloat x = idx*scrollView.bounds.size.width;
    [scrollView scrollRectToVisible:CGRectMake(x, 0, scrollView.bounds.size.width, scrollView.bounds.size.height) animated:YES];
}


#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    pageControl.currentPage = MAX(0, MIN(idx, pageControl.numberOfPages-1));
    
    UIButton* button = [tutorialButtons objectAtIndex:MAX(0, MIN([tutorialButtons count] - 1, pageControl.currentPage))];
    button.selected = YES;
    [[tutorialButtons arrayByRemovingObject:button] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setSelected:NO];
    }];
    
    
    int location = scrollView.bounds.size.width - (int)scrollView.contentOffset.x % (int)scrollView.bounds.size.width;
    CGRect fr = separator.frame;
    fr.origin.x = location;
    separator.frame = fr;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)_scrollView{
    [scrollView.subviews makeObjectsPerformSelector:@selector(pauseAnimating)];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)_scrollView{
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    MMVideoLoopView* visible = [scrollView.subviews objectAtIndex:idx];
    if(![visible isBuffered]){
        [scrollView.subviews makeObjectsPerformSelector:@selector(stopAnimating)];
    }
    [visible startAnimating];
    [self.delegate userIsViewingTutorialStep:idx];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)_scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}


#pragma mark - Tutorial Loading

-(void) loadTutorials{
    NSArray* tutorials = [[MMTutorialManager sharedInstance] tutorialSteps];
    
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* videoURL = [obj objectForKey:@"video"];
        NSString* videoTitle = [obj objectForKey:@"title"];
        NSString* videoId = [obj objectForKey:@"id"];
        NSURL* tutorialMov = [[NSBundle mainBundle] URLForResource:videoURL withExtension:nil];
        MMVideoLoopView* tutorial = [[MMVideoLoopView alloc] initForVideo:tutorialMov withTitle:videoTitle forVideoId:videoId];
        [scrollView addSubview:tutorial];

        CGRect fr = scrollView.bounds;
        fr.origin.x = idx * fr.size.width;
        tutorial.frame = fr;
        [tutorial stopAnimating];
    }];
    
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * [tutorials count], scrollView.bounds.size.height);
    [(MMVideoLoopView*)scrollView.subviews.firstObject startAnimating];
    
    pageControl.numberOfPages = [tutorials count];
    pageControl.currentPage = 0;
    
    
    

    CGFloat widthForButtonCenters = rotateableTutorialSquare.bounds.size.width;
    CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;
    widthForButtonCenters = widthForButtonCenters - 2 * buttonBuffer;
    widthForButtonCenters = widthForButtonCenters - kWidthOfSidebarButton;
    widthForButtonCenters -= 100;
    CGFloat stepForEachButton = widthForButtonCenters / [tutorials count];
    CGFloat startX = (rotateableTutorialSquare.bounds.size.width - widthForButtonCenters) / 2;
    
    tutorialButtons = [NSMutableArray array];
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MMTutorialButton* button = [[MMTutorialButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)
                                                             forStepNumber:idx+1];
        button.tag = idx;
        CGPoint center = CGPointMake(startX + stepForEachButton * idx, kWidthOfSidebarButton / 2 + kWidthOfSidebarButtonBuffer);
        button.center = center;
        
        if(idx == 0){
            button.selected = YES;
        }
        
        [button addTarget:self action:@selector(didTapToChangeToTutorial:) forControlEvents:UIControlEventTouchUpInside];
        
        [tutorialButtons addObject:button];
        [rotateableTutorialSquare addSubview:button];
    }];
    
    MMCheckButton* checkButton = [[MMCheckButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    CGPoint center = CGPointMake(startX + widthForButtonCenters, kWidthOfSidebarButton / 2 + kWidthOfSidebarButtonBuffer);
    checkButton.center = center;
    checkButton.tag = NSIntegerMax;
    [tutorialButtons addObject:checkButton];
    [rotateableTutorialSquare addSubview:checkButton];
    [checkButton addTarget:self action:@selector(didTapToChangeToTutorial:) forControlEvents:UIControlEventTouchUpInside];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [UIView animateWithDuration:.2 animations:^{
                rotateableTutorialSquare.transform = CGAffineTransformMakeRotation([self interfaceRotationAngle]);
            }];
        }
    });
}

#pragma mark - Button Helpers

-(void) didTapToChangeToTutorial:(MMTutorialButton*)button{
    NSInteger tutorialIndex = button.tag;
    if(tutorialIndex == NSIntegerMax){
        // end the tutorial
        [self.delegate didFinishTutorial];
        return;
    }
    CGRect squareOfTutorial = CGRectMake(tutorialIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    [scrollView scrollRectToVisible:squareOfTutorial animated:YES];
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


@end
