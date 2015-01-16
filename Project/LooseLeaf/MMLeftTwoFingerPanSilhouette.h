//
//  MMTwoFingerPanSilhouette.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMLeftTwoFingerPanSilhouette : NSObject{
    UIBezierPath* openPath;
    UIBezierPath* closedPath;

    UIBezierPath* openMiddleFingerTipPath;
    UIBezierPath* openIndexFingerTipPath;
    UIBezierPath* closedMiddleFingerTipPath;
    UIBezierPath* closedIndexFingerTipPath;
}

-(void) openTo:(CGFloat)openPercent;

-(UIBezierPath*) pathForTouches:(NSSet*)touches;
-(CGPoint) locationOfIndexFingerInPathBoundsForTouches:(NSSet*)touches;


@end
