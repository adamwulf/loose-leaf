//
//  UIDevice+PPI.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDevice (PPI)

+ (BOOL)isMetric;

+ (CGFloat)ppi;

+ (CGFloat)ppc;

+ (CGFloat)idealUnitLength;

+ (NSInteger)majorVersion;

+ (NSString*)buildVersion;

+ (CGFloat)advisedMaxImportDim;

@end
