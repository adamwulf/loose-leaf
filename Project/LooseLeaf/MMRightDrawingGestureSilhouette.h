//
//  MMHandPathHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <DrawKit-iOS/DrawKit-iOS.h>

@interface MMRightDrawingGestureSilhouette : NSObject{
    CGRect boundingBox;
    UIBezierPath* pointerFingerPath;
    UIBezierPath* indexFingerTipPath;
}

@property (readonly) UIBezierPath* pointerFingerPath;

-(UIBezierPath*) pathForTouch:(UITouch*)touch;
-(CGPoint) locationOfIndexFingerInPathBoundsForTouch:(UITouch*)touch;

@end
