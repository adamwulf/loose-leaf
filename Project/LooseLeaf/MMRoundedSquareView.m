//
//  MMRoundedSquareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMRoundedSquareView.h"
#import "MMRotationManager.h"
#import "MMUntouchableTutorialView.h"

@implementation MMRoundedSquareView{
    UIView* fadedBackground;
}

@synthesize rotateableSquareView;
@synthesize maskedScrollContainer;

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        // 10% buffer
        CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;
        
        //
        // faded background
        
        fadedBackground = [[UIView alloc] initWithFrame:self.bounds];
        fadedBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        
        UIButton* backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundButton.bounds = fadedBackground.bounds;
        [backgroundButton addTarget:self action:@selector(tapToClose) forControlEvents:UIControlEventTouchUpInside];
        [fadedBackground addSubview:backgroundButton];
        backgroundButton.center = fadedBackground.center;
        
        [self addSubview:fadedBackground];
        
        
        CGFloat widthOfRotateableContainer = self.boxSize + 2 * buttonBuffer;
        rotateableSquareView = [[MMUntouchableTutorialView alloc] initWithFrame:CGRectMake((self.bounds.size.width - widthOfRotateableContainer) / 2,
                                                                                               (self.bounds.size.height - widthOfRotateableContainer) / 2,
                                                                                               widthOfRotateableContainer,
                                                                                               widthOfRotateableContainer)];
        [self addSubview:rotateableSquareView];
        
        
        //
        // scrollview
        CGPoint boxOrigin = CGPointMake(buttonBuffer, buttonBuffer);
        maskedScrollContainer = [[UIView alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y, self.boxSize, self.boxSize)];
        
        CAShapeLayer* scrollMaskLayer = [CAShapeLayer layer];
        scrollMaskLayer.backgroundColor = [UIColor clearColor].CGColor;
        scrollMaskLayer.fillColor = [UIColor whiteColor].CGColor;
        scrollMaskLayer.path = [self roundedRectPathForBoxSize:self.boxSize withOrigin:CGPointZero].CGPath;
        maskedScrollContainer.layer.mask = scrollMaskLayer;
        [rotateableSquareView addSubview:maskedScrollContainer];

    }
    return self;
}

-(CGFloat) boxSize{
    return 600;
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
                rotateableSquareView.transform = CGAffineTransformMakeRotation([self interfaceRotationAngle]);
            }];
        }
    });
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

#pragma mark - Actions

-(void) tapToClose{
    [self.delegate didTapToCloseRoundedSquareView:self];
}


@end
