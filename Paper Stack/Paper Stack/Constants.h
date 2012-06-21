//
//  Contants.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Paper_Stack_Contants_h
#define Paper_Stack_Contants_h


#ifdef DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

#define kGutterWidthToDragPages 300

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

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


#endif
