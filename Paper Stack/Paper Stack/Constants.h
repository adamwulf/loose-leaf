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

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]


#define kAnimationDelay 0.05

#define kListPageZoom .25
#define kZoomToListPageZoom .4
#define kMinPageZoom .7
#define kMaxPageZoom 2.5

#define kGutterWidthToDragPages 500
#define kFingerWidth 40
#define kFilteringFactor 0.2
#define kStartOfSidebar 212
#define kWidthOfSidebarButton 50.0
#define kWidthOfSidebarButtonBuffer 5
#define kWidthOfSidebar 80
#define kMinScaleDelta .01
#define kShadowDepth 7
#define kShadowBend 3
#define kBezelInGestureWidth 20

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

enum {
    SLScaleDirectionNone = 0,
    SLScaleDirectionLarger  = 1 << 0,
    SLScaleDirectionSmaller   = 1 << 1
};
typedef NSUInteger SLBezelScaleDirection;


#endif
