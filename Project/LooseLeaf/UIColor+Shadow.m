//
//  UIColor+Shadow.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIColor+Shadow.h"

@implementation UIColor (Shadow)

static UIColor* shadowColor;
+(UIColor*)shadowColor{
    if(shadowColor){
        return shadowColor;
    }
    shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
    return shadowColor;
}


@end
