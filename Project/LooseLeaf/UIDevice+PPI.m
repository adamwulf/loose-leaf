//
//  UIDevice+PPI.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIDevice+PPI.h"

@implementation UIDevice (PPI)

+(CGFloat) ppi{
    return 163;
}

// points per cm
+(CGFloat) ppc{
    return [UIDevice ppi] / 2.54;
}

@end
