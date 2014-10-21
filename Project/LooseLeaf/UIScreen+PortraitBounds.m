//
//  UIScreen+PortraitBounds.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/16/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIScreen+PortraitBounds.h"

@implementation UIScreen (PortraitBounds)

-(CGRect) portraitBounds{
    CGRect b = [self bounds];
    if(b.size.width > b.size.height){
        CGFloat t = b.size.height;
        b.size.height = b.size.width;
        b.size.width = t;
    }
    return b;
}

@end
