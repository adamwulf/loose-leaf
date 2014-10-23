//
//  UIView+Debug.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/25/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIView+Debug.h"
#import <QuartzCore/QuartzCore.h>
#import <DrawKit-iOS/JRSwizzle.h>
#import <JotUI/JotUI.h>


@implementation UIView (Debug)

-(void) showDebugBorder{
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 2;
}

-(int) fullByteSize{
    return self.bounds.size.width * self.contentScaleFactor * self.bounds.size.height * self.contentScaleFactor * 4;
}

-(void) swizzle_removeFromSuperview{
    CheckMainThread;
    [self swizzle_removeFromSuperview];
}

+(void)load{
    NSError *error = nil;
	[UIView jr_swizzleMethod:@selector(removeFromSuperview)
                        withMethod:@selector(swizzle_removeFromSuperview)
                             error:&error];
}

@end
