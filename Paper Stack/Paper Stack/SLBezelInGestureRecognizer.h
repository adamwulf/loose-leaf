//
//  SLBezelGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

enum {
    SLBezelDirectionFromRightBezel  = 1 << 0,
    SLBezelDirectionFromLeftBezel   = 1 << 1,
    SLBezelDirectionFromTopBezel    = 1 << 2,
    SLBezelDirectionFromBottomBezel = 1 << 3
};
typedef NSUInteger SLBezelDirection;

enum {
    SLBezelDirectionNone = 0,
    SLBezelDirectionRight  = 1 << 0,
    SLBezelDirectionLeft   = 1 << 1,
    SLBezelDirectionUp    = 1 << 2,
    SLBezelDirectionDown = 1 << 3
};
typedef NSUInteger SLBezelPanDirection;



@interface SLBezelInGestureRecognizer : UIPanGestureRecognizer{
    
    SLBezelDirection bezelDirectionMask;
    SLBezelPanDirection panDirection;
    CGPoint lastKnownLocation;
    CGPoint firstKnownLocation;
}

@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelPanDirection panDirection;


@end
