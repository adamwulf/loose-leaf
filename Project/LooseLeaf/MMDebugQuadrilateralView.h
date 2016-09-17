//
//  MMDebugQuadrilateralView.h
//  ShapeShifter
//
//  Created by Adam Wulf on 2/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

// A helpful debug view that will draw the
// quad on screen that will be used to
// transform the image
@interface MMDebugQuadrilateralView : UIView

-(void) setQuadrilateral:(Quadrilateral)q;

@end
