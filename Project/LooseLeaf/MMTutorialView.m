//
//  MMTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialView.h"
#import "MMVideoLoopView.h"
#import "AVHexColor.h"
#import "UIColor+Shadow.h"

@implementation MMTutorialView{
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
        UIBezierPath* box = [self boxPathForWidth:boxSize];
        
        //
        // faded background
        
        fadedBackground = [[UIView alloc] initWithFrame:self.bounds];
        
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = self.bounds;
        shapeLayer.position = self.center;
        shapeLayer.path = box.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = [UIColor blackColor].CGColor;

        CALayer* greyBackground = [CALayer layer];
        greyBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        greyBackground.bounds = self.bounds;
        greyBackground.position = self.center;
        greyBackground.mask = shapeLayer;
        [fadedBackground.layer addSublayer:greyBackground];
        [self addSubview:fadedBackground];
        
        //
        // scrollview
        
        CGPoint boxOrigin = [self topLeftCornerForBoxSize:boxSize];
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
        [self addSubview:maskedScrollContainer];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y + boxSize-40, boxSize, 40)];
        pageControl.pageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
        pageControl.userInteractionEnabled = NO;
        pageControl.currentPageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        [self addSubview:pageControl];

        
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
    NSLog(@"next!");
    
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
    NSArray* tutorials = @[@{
        @"title":@"Draw a Circle",
        @"video":@"ruler-circle.mov"
    },@{
        @"title":@"Clone a Photo",
        @"video":@"stretch-in-app-alt-2.mov"
    },@{
        @"title":@"Draw a Curve",
        @"video":@"ruler-for-curve-2.mov"
    },@{
        @"title":@"Draw on your Photos",
        @"video":@"draw-clip-2-2.mov"
    }];
    
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* videoURL = [obj objectForKey:@"video"];
        NSString* videoTitle = [obj objectForKey:@"title"];
        NSURL* tutorialMov = [[NSBundle mainBundle] URLForResource:videoURL withExtension:nil];
        MMVideoLoopView* tutorial = [[MMVideoLoopView alloc] initForVideo:tutorialMov withTitle:videoTitle];
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

-(UIBezierPath*) boxPathForWidth:(CGFloat)width{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:self.bounds];
    CGPoint boxOrigin = [self topLeftCornerForBoxSize:width];
    [path appendPath:[self roundedRectPathForBoxSize:width withOrigin:boxOrigin]];
    path.usesEvenOddFillRule = YES;
    return path;
}

@end
