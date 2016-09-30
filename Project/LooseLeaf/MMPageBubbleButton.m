//
//  MMPageBubbleButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPageBubbleButton.h"


@implementation MMPageBubbleButton

@dynamic scale;
@dynamic originalViewScale;


+ (CGFloat)idealScaleForView:(MMEditablePaperView*)page {
    return 1.0;
}

+ (CGAffineTransform)idealTransformForView:(MMEditablePaperView*)page {
    // aim to get the border into 36 px
    CGFloat scale = [MMPageBubbleButton idealScaleForView:page];
    return CGAffineTransformMakeScale(scale, scale);
}

@end
