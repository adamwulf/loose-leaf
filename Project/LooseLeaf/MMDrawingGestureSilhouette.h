//
//  MMHandPathHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMDrawingGestureSilhouette : NSObject

@property (readonly) UIBezierPath* pointerFingerPath;
@property (readonly) CGPoint currentOffset;

-(UIBezierPath*) pathForTouch:(UITouch*)touch;
-(CGPoint) locationOfIndexFingerInPathBoundsForTouch:(UITouch*)touch;

@end
