//
//  UIPopoverView+SuperWatch.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIView+SuperWatch.h"
#import <DrawKit-iOS/JRSwizzle.h>
#import "NSThread+BlockAdditions.h"
#import "MMShareManager.h"
#import "MMShareView.h"

@implementation UIView (SuperWatch)


// when adding views, check if we're in sharing mode. if so,
// we need to register any view that's been added to the Window,
// and also register any collection views.
-(void) swizzle_addSubview:(UIView *)view{
    if([MMShareManager shouldListenToRegisterViews]){
        if([view isKindOfClass:[UICollectionView class]]){
            [[MMShareManager sharedInstace] addCollectionView:(UICollectionView*)view];
        }else if([self isKindOfClass:[UIWindow class]]){
            [[MMShareManager sharedInstace] registerDismissView:view];
        }
    }
    [self swizzle_addSubview:view];
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
    }
}

-(CGPoint) swizzle_convertPoint:(CGPoint)point fromView:(UIView *)view{
    NSArray* allCollectionViews = [[MMShareManager sharedInstace] allFoundCollectionViews];
    if([allCollectionViews count]){
        return CGPointMake(20, 20);
    }
    return [self swizzle_convertPoint:point fromView:view];
}


@end
