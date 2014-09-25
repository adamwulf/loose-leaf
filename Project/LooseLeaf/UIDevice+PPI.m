//
//  UIDevice+PPI.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIDevice+PPI.h"
#import "EPPZDevice.h"

@implementation UIDevice (PPI)

+(CGFloat) ppi{
    // source: http://dpi.lv
    
    NSString* machineId = [[EPPZDevice sharedDevice] machineID];
    if([machineId isEqualToString:@"iPad1,1"]){
        return 132; // 1st gen ipad
    }else if([machineId isEqualToString:@"iPad2,1"]){
        return 132; // ipad 2
    }else if([machineId isEqualToString:@"iPad2,2"]){
        return 132; // ipad 2
    }else if([machineId isEqualToString:@"iPad2,3"]){
        return 132; // ipad 2
    }else if([machineId isEqualToString:@"iPad2,4"]){
        return 132; // ipad 2
    }else if([machineId isEqualToString:@"iPad2,5"]){
        return 163; // ipad mini
    }else if([machineId isEqualToString:@"iPad2,6"]){
        return 163; // ipad mini
    }else if([machineId isEqualToString:@"iPad2,7"]){
        return 163; // ipad mini
    }else if([machineId isEqualToString:@"iPad3,1"]){
        return 264; // iPad 3
    }else if([machineId isEqualToString:@"iPad3,2"]){
        return 264; // iPad 3
    }else if([machineId isEqualToString:@"iPad3,3"]){
        return 264; // iPad 3
    }else if([machineId isEqualToString:@"iPad3,4"]){
        return 264; // iPad 4
    }else if([machineId isEqualToString:@"iPad3,5"]){
        return 264; // iPad 4
    }else if([machineId isEqualToString:@"iPad3,6"]){
        return 264; // iPad 4
    }else if([machineId isEqualToString:@"iPad4,1"]){
        return 264; // iPad Air
    }else if([machineId isEqualToString:@"iPad4,2"]){
        return 264; // iPad Air
    }else if([machineId isEqualToString:@"iPad4,3"]){
        return 264; // iPad Air (China)
    }else if([machineId isEqualToString:@"iPad4,4"]){
        return 326; // ipad mini retina
    }else if([machineId isEqualToString:@"iPad4,5"]){
        return 326; // ipad mini retina
    }else if([machineId isEqualToString:@"iPad4,6"]){
        return 326; // ipad mini retina
    }
    
    // ipad air: 264
    // ipad retina: 264
    // ipad mini retina: 326
    // ipad mini: 163
    // ipad 2: 132
    // ipad 3: 264 // same as ipad retina
    
    // default, assume retina screen
    return 264;
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
