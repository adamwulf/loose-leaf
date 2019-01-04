//
//  UIColor+LooseLeaf.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/25/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "UIColor+LooseLeaf.h"
#import "AVHexColor.h"


@implementation UIColor (LooseLeaf)

+ (UIColor*)blueInkColor {
    return [AVHexColor colorWithHexString:@"3C7BFF"];
}

+ (UIColor*)redInkColor {
    return [AVHexColor colorWithHexString:@"E8373E"];
}

+ (UIColor*)yellowInkColor {
    return [AVHexColor colorWithHexString:@"FFE230"];
}

+ (UIColor*)greenInkColor {
    return [AVHexColor colorWithHexString:@"5EF52E"];
}

@end
