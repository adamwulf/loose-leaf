//
//  MMScrapBubbleView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBubbleButton.h"
#import "MMScrapBorderView.h"
#import <PerformanceBezier/PerformanceBezier.h>
#import <ClippingBezier/ClippingBezier.h>
#import "Constants.h"


@implementation MMScrapBubbleButton {
    CGFloat lastRotationTransform;
    CGFloat rotationAdjustment;
    MMScrapBorderView* borderView;
}

@synthesize view;
@synthesize rotationAdjustment;
@synthesize originalViewScale;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        rotationAdjustment = 0;
        lastRotationTransform = 0;
        self.rotation = 0;
        borderView = [[MMScrapBorderView alloc] initWithFrame:self.bounds];
        [self addSubview:borderView];
    }
    return self;
}

#pragma mark - Rotation

/**
 * we need to adjust for our rotation when the scrap is added
 * to the bubble. when the scrap is added, we need to be at
 * rotation = 0, so the rotationAdjustment accounts for that
 */
- (CGAffineTransform)rotationTransform {
    lastRotationTransform = [self.delegate sidebarButtonRotation];
    return CGAffineTransformMakeRotation([self.delegate sidebarButtonRotation] - rotationAdjustment);
}

- (void)setRotation:(CGFloat)_rotation {
    [super setRotation:_rotation];
    if (ABS(lastRotationTransform - [self.delegate sidebarButtonRotation]) > 0.01) {
        self.transform = CGAffineTransformScale([self rotationTransform], scale, scale);
    }
}

#pragma mark - Scrap

+ (CGFloat)idealScaleForView:(MMScrapView*)scrap {
    return 36.0 / MAX(scrap.originalSize.width, scrap.originalSize.height);
}

+ (CGAffineTransform)idealTransformForView:(MMScrapView*)scrap {
    // aim to get the border into 36 px
    CGFloat scale = [MMScrapBubbleButton idealScaleForView:scrap];
    return CGAffineTransformConcat(CGAffineTransformMakeRotation(scrap.rotation), CGAffineTransformMakeScale(scale, scale));
}

- (void)setView:(MMScrapView*)_scrap {
    view = _scrap;
    if (!_scrap) {
        //        DebugLog(@"killing scrap bubble, setting to nil scrap");
        [borderView setHidden:YES];
        return;
    }
    rotationAdjustment = self.rotation;

    // force transform update
    CGFloat foo = self.rotation;
    self.rotation = -foo;
    self.rotation = foo;

    [self insertSubview:view belowSubview:borderView];
    view.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    view.transform = [MMScrapBubbleButton idealTransformForView:view];
    UIBezierPath* idealScaledPathInButton = [view.bezierPath copy];
    [idealScaledPathInButton applyTransform:view.transform];

    // find the first point of the path compared
    // to the first point of the scrap's path
    // and line these up
    CGPoint firstscrappoint = [view.bezierPath firstPoint];
    firstscrappoint = [self convertPoint:firstscrappoint fromView:view];
    CGPoint firstpathpoint = [idealScaledPathInButton firstPoint];
    CGFloat diffX = firstscrappoint.x - firstpathpoint.x;
    CGFloat diffY = firstscrappoint.y - firstpathpoint.y;
    [idealScaledPathInButton applyTransform:CGAffineTransformMakeTranslation(diffX, diffY)];
    //
    // now the path and the scrap are lined up, but the
    // scrap's center and the path center don't actually
    // agree out of the box (unknown why). things actually
    // look better if we average their centers
    //
    // let's move the scrap and the path to the average
    // of the two centers
    CGPoint pathCenter = CGPointMake(idealScaledPathInButton.bounds.origin.x + idealScaledPathInButton.bounds.size.width / 2, idealScaledPathInButton.bounds.origin.y + idealScaledPathInButton.bounds.size.height / 2);
    diffX = view.center.x - pathCenter.x;
    diffY = view.center.y - pathCenter.y;
    CGAffineTransform centerTransform = CGAffineTransformMakeTranslation(diffX / 2, diffY / 2);
    [idealScaledPathInButton applyTransform:centerTransform];
    view.center = CGPointApplyAffineTransform(view.center, centerTransform);

    // now let the border know about it's path
    // to draw
    [borderView setBezierPath:idealScaledPathInButton];
}


#pragma mark - Properties


- (UIColor*)borderColor {
    return [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:0.35];
}

- (UIColor*)backgroundColor {
    return [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawCircleBackground:rect];
}

#pragma mark - Ignore Touches


/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    if ([super hitTest:point withEvent:event]) {
        return self;
    }
    return nil;
}

@end
