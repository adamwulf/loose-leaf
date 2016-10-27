//
//  MMPagesSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/19/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPagesSidebarButton.h"


@implementation MMPagesSidebarButton

+ (CGFloat)scaleOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width {
    return width / view.bounds.size.width;
}

+ (CGSize)sizeOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width {
    CGFloat scale = width / view.bounds.size.width;
    CGSize s = CGSizeMake(view.bounds.size.width * scale, view.bounds.size.height * scale);
    return s;
}

- (void)setView:(UIView<MMUUIDView>*)view {
    view.transform = CGAffineTransformIdentity;
    [super setView:view];
}


@end
