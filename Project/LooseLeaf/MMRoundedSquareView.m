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
#import "Constants.h"


@implementation MMRoundedSquareView

@synthesize rotateableSquareView;
@synthesize maskedScrollContainer;
@synthesize allowTappingOutsideToClose;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        allowTappingOutsideToClose = YES;

        // 10% buffer
        CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;

        //
        // faded background

        UIButton* backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundButton.bounds = self.bounds;
        [backgroundButton addTarget:self action:@selector(tapToClose) forControlEvents:UIControlEventTouchUpInside];
        backgroundButton.center = CGRectGetMidPoint([self bounds]);
        backgroundButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self addSubview:backgroundButton];


        CGFloat widthOfRotateableContainer = self.boxSize + 2 * buttonBuffer;
        rotateableSquareView = [[MMUntouchableTutorialView alloc] initWithFrame:CGRectMake((self.bounds.size.width - widthOfRotateableContainer) / 2,
                                                                                           (self.bounds.size.height - widthOfRotateableContainer) / 2,
                                                                                           widthOfRotateableContainer,
                                                                                           widthOfRotateableContainer)];
        [self addSubview:rotateableSquareView];


        self.rotateableSquareView.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;

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

- (CGFloat)boxSize {
    return 600;
}

#pragma mark - Private Helpers

- (CGPoint)topLeftCornerForBoxSize:(CGFloat)width {
    return CGPointMake((self.bounds.size.width - width) / 2, (self.bounds.size.height - width) / 2);
}

- (UIBezierPath*)roundedRectPathForBoxSize:(CGFloat)width withOrigin:(CGPoint)boxOrigin {
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(boxOrigin.x, boxOrigin.y, width, width)
                                 byRoundingCorners:UIRectCornerAllCorners
                                       cornerRadii:CGSizeMake(width / 10, width / 10)];
}

#pragma mark - Actions

- (void)tapToClose {
    if (self.allowTappingOutsideToClose) {
        [self.delegate didTapToCloseRoundedSquareView:self];
    }
}

@end
