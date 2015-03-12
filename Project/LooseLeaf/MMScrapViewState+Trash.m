//
//  MMScrapViewState+Trash.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapViewState+Trash.h"
#import <ClippingBezier/JRSwizzle.h>
#import <objc/runtime.h>

static char SHOULD_FORGET;

@implementation MMScrapViewState (Trash)

#pragma mark - Property

-(void) freeIsForgetfulProperty{
    objc_setAssociatedObject(self, &SHOULD_FORGET, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setIsForgetful:(BOOL)_forgetful{
    [self freeIsForgetfulProperty];
    objc_setAssociatedObject(self, &SHOULD_FORGET, [NSNumber numberWithBool:_forgetful], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    drawableViewState.isForgetful = _forgetful;
}

-(BOOL)isForgetful{
    NSNumber* ret = objc_getAssociatedObject(self, &SHOULD_FORGET);
    return [ret boolValue];
}


#pragma mark - Forget Edits

-(BOOL) swizzle_hasEditsToSave{
    if([self isForgetful]){
        return NO;
    }
    return [self swizzle_hasEditsToSave];
}


#pragma mark - Dealloc

-(void) swizzle_dealloc{
    [self freeIsForgetfulProperty];
    [self swizzle_dealloc];
}


#pragma mark - Swizzle


+(void)load{
    @autoreleasepool {
        NSError *error = nil;
        [MMScrapViewState jr_swizzleMethod:@selector(hasEditsToSave)
                                withMethod:@selector(swizzle_hasEditsToSave)
                                     error:&error];
        [MMScrapViewState jr_swizzleMethod:@selector(dealloc)
                                withMethod:@selector(swizzle_dealloc)
                                     error:&error];
    }
}

@end
