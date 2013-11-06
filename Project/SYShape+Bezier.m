//
//  SYShape+Bezier.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "SYShape+Bezier.h"
#import "DrawKit-iOS.h"

@implementation SYShape (Bezier)

-(UIBezierPath*) bezierPath{
    UIBezierPath* output = [UIBezierPath bezierPath];
    for(SYGeometry* geom in self.geometries){
        if([output elementCount]){
            [output appendPathRemovingInitialMoveToPoint:[geom bezierPath]];
        }else{
            [output appendPath:[geom bezierPath]];
        }
    }
    if(self.isClosedCurve){
        [output closePath];
    }
    return output;
}


@end
