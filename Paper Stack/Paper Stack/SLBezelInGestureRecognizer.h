//
//  SLBezelGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"


@interface SLBezelInGestureRecognizer : UIPanGestureRecognizer{
    
    SLBezelDirection bezelDirectionMask;
    SLBezelPanDirection panDirection;
    CGPoint lastKnownLocation;
    CGPoint firstKnownLocation;
}

@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelPanDirection panDirection;


@end
