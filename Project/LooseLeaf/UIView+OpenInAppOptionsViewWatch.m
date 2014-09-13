//
//  UIPopoverView+SuperWatch.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <DrawKit-iOS/JRSwizzle.h>
#import "UIView+OpenInAppOptionsViewWatch.h"
#import "NSThread+BlockAdditions.h"
#import "MMOpenInAppManager.h"
#import "MMOpenInAppOptionsView.h"

@implementation UIView (OpenInAppOptionsViewWatch)


// when adding views, check if we're in sharing mode. if so,
// we need to register any view that's been added to the Window,
// and also register any collection views.
-(void) swizzle_addSubview:(UIView *)view{
    if([MMOpenInAppManager shouldListenToRegisterViews]){
        if([view isKindOfClass:[UICollectionView class]]){
            [[MMOpenInAppManager sharedInstance] addCollectionView:(UICollectionView*)view];
        }else if([self isKindOfClass:[UIWindow class]]){
            [[MMOpenInAppManager sharedInstance] registerDismissView:view];
        }
    }
    [self swizzle_addSubview:view];
}

-(void) swizzle_insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview{
    if([MMOpenInAppManager shouldListenToRegisterViews]){
        if([view isKindOfClass:[UICollectionView class]]){
            [[MMOpenInAppManager sharedInstance] addCollectionView:(UICollectionView*)view];
        }else if([self isKindOfClass:[UIWindow class]]){
            [[MMOpenInAppManager sharedInstance] registerDismissView:view];
        }
    }
    [self swizzle_insertSubview:view aboveSubview:siblingSubview];
}

-(void) swizzle_insertSubview:(UIView *)view atIndex:(NSInteger)index{
    if([MMOpenInAppManager shouldListenToRegisterViews]){
        if([view isKindOfClass:[UICollectionView class]]){
            [[MMOpenInAppManager sharedInstance] addCollectionView:(UICollectionView*)view];
        }else if([self isKindOfClass:[UIWindow class]]){
            [[MMOpenInAppManager sharedInstance] registerDismissView:view];
        }
    }
    [self swizzle_insertSubview:view atIndex:index];
}

-(void) swizzle_insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview{
    if([MMOpenInAppManager shouldListenToRegisterViews]){
        if([view isKindOfClass:[UICollectionView class]]){
            [[MMOpenInAppManager sharedInstance] addCollectionView:(UICollectionView*)view];
        }else if([self isKindOfClass:[UIWindow class]]){
            [[MMOpenInAppManager sharedInstance] registerDismissView:view];
        }
    }
    [self swizzle_insertSubview:view belowSubview:siblingSubview];
}

+(void)load{
    @autoreleasepool {
        NSError *error = nil;
        [UIView jr_swizzleMethod:@selector(addSubview:)
                            withMethod:@selector(swizzle_addSubview:)
                                      error:&error];
        [UIView jr_swizzleMethod:@selector(convertPoint:fromView:)
                      withMethod:@selector(swizzle_convertPoint:fromView:)
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
}

-(CGPoint) swizzle_convertPoint:(CGPoint)point fromView:(UIView *)view{
    if(self == [MMOpenInAppManager shareTargetView]){
        NSArray* allCollectionViews = [[MMOpenInAppManager sharedInstance] allFoundCollectionViews];
        if([allCollectionViews count]){
            return CGPointMake(20, 20);
        }
    }
    return [self swizzle_convertPoint:point fromView:view];
}


@end
