//
//  MMLeftDrawingGestureSilhouette.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/19/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMLeftDrawingGestureSilhouette.h"

@implementation MMLeftDrawingGestureSilhouette


-(id) init{
    if(self = [super init]){
        // transform paths
        [self flipPathAroundYAxis:pointerFingerPath];
        [self flipPathAroundYAxis:indexFingerTipPath];
    }
    return self;
}

-(void) flipPathAroundYAxis:(UIBezierPath*)path{
    [path applyTransform:CGAffineTransformMakeTranslation(-boundingBox.size.width/2 - boundingBox.origin.x, 0)];
    [path applyTransform:CGAffineTransformMakeScale(-1, 1)];
    [path applyTransform:CGAffineTransformMakeTranslation(boundingBox.size.width/2 + boundingBox.origin.x, 0)];
    
}

@end
