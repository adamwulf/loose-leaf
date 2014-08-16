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

// will return points per in/cm depending
// on user's locale
+(CGFloat) idealUnitLength{
    NSLocale *locale = [NSLocale currentLocale];
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    if(isMetric){
        return [self ppc];
    }else{
        return [self ppi];
    }
}

+(NSInteger) majorVersion{
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    return [[vComp objectAtIndex:0] integerValue];
}

@end
