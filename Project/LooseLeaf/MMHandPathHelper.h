//
//  MMHandPathHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMHandPathHelper : NSObject

@property (readonly) UIBezierPath* pointerFingerPath;
@property (readonly) CGPoint currentOffset;

@end
