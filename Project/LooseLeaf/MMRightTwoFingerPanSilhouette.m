//
//  MMRightTwoFingerPanSilhouette.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/15/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMRightTwoFingerPanSilhouette.h"

@implementation MMRightTwoFingerPanSilhouette

-(id) init{
    if(self = [super init]){
        // transform paths
        
        [self flipPathAroundYAxis:openPath];
        [self flipPathAroundYAxis:closedPath];

        [self flipPathAroundYAxis:openMiddleFingerTipPath];
        [self flipPathAroundYAxis:openIndexFingerTipPath];
        [self flipPathAroundYAxis:closedMiddleFingerTipPath];
        [self flipPathAroundYAxis:closedIndexFingerTipPath];

        handLayer.path = openPath.CGPath;
    }
    return self;
}

-(void) flipPathAroundYAxis:(UIBezierPath*)path{
    CGRect bounds = path.bounds;
    [closedPath applyTransform:CGAffineTransformMakeTranslation(-bounds.size.width/2 - bounds.origin.x, 0)];
    [closedPath applyTransform:CGAffineTransformMakeScale(-1, 1)];
    [closedPath applyTransform:CGAffineTransformMakeTranslation(bounds.size.width/2 + bounds.origin.x, 0)];

}

@end
