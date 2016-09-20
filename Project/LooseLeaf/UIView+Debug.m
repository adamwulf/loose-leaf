//
//  UIView+Debug.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/25/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIView+Debug.h"
#import <QuartzCore/QuartzCore.h>
#import <ClippingBezier/JRSwizzle.h>
#import <JotUI/JotUI.h>


@implementation UIView (Debug)

- (void)showDebugBorder {
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 2;
}

- (int)fullByteSize {
    return self.bounds.size.width * self.contentScaleFactor * self.bounds.size.height * self.contentScaleFactor * 4;
}

#ifdef DEBUG

- (void)swizzle_addSubview:(UIView*)view {
    CheckMainThread;
    [self swizzle_addSubview:view];
}

- (void)swizzle_insertSubview:(UIView*)view aboveSubview:(UIView*)siblingSubview {
    CheckMainThread;
    [self swizzle_insertSubview:view aboveSubview:siblingSubview];
}

- (void)swizzle_insertSubview:(UIView*)view atIndex:(NSInteger)index {
    CheckMainThread;
    [self swizzle_insertSubview:view atIndex:index];
}

- (void)swizzle_insertSubview:(UIView*)view belowSubview:(UIView*)siblingSubview {
    CheckMainThread;
    [self swizzle_insertSubview:view belowSubview:siblingSubview];
}

- (void)swizzle_removeFromSuperview {
    CheckMainThread;
    [self swizzle_removeFromSuperview];
}

+ (void)load {
    NSError* error = nil;
    [UIView jr_swizzleMethod:@selector(removeFromSuperview)
                  withMethod:@selector(swizzle_removeFromSuperview)
                       error:&error];
    [UIView jr_swizzleMethod:@selector(addSubview:)
                  withMethod:@selector(swizzle_addSubview:)
                       error:&error];
    [UIView jr_swizzleMethod:@selector(insertSubview:aboveSubview:)
                  withMethod:@selector(swizzle_insertSubview:aboveSubview:)
                       error:&error];
    [UIView jr_swizzleMethod:@selector(insertSubview:atIndex:)
                  withMethod:@selector(swizzle_insertSubview:atIndex:)
                       error:&error];
    [UIView jr_swizzleMethod:@selector(insertSubview:belowSubview:)
                  withMethod:@selector(swizzle_insertSubview:belowSubview:)
                       error:&error];
}

#endif

@end
