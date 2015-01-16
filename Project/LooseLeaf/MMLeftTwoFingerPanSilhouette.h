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

-(UIBezierPath*) pathForTouches:(NSArray*)touches;
-(CGPoint) locationOfIndexFingerInPathBoundsForTouches:(NSArray*)touches;

-(void) setFingerDistance:(CGFloat)distance;

#pragma mark - Debug

-(void) openTo:(CGFloat)openPercent;

@end
