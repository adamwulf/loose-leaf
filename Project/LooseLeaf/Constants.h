//
//  Contants.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
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

// List View
#define kNumberOfColumnsInListView 3
#define kListPageZoom .25

// List View Gesture
#define kZoomToListPageZoom .4
#define kMinPageZoom .7
#define kMaxPageZoom 2.0
#define kMaxPageResolution 1.5

// Page View
#define kGutterWidthToDragPages 500
#define kFingerWidth 40
#define kFilteringFactor 0.2
#define kStartOfSidebar 290
#define kWidthOfSidebarButton 60.0
#define kWidthOfSidebarButtonBuffer 10
#define kWidthOfSidebar 80
#define kMinScaleDelta .01
#define kShadowDepth 7
#define kShadowBend 3
#define kBezelInGestureWidth 20
#define kUndoLimit 20

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

enum {
    MMBezelDirectionNone = 0,
    MMBezelDirectionRight  = 1 << 0,
    MMBezelDirectionLeft   = 1 << 1,
    MMBezelDirectionUp    = 1 << 2,
    MMBezelDirectionDown = 1 << 3
};
typedef NSUInteger MMBezelDirection;

enum {
    MMScaleDirectionNone = 0,
    MMScaleDirectionLarger  = 1 << 0,
    MMScaleDirectionSmaller   = 1 << 1
};
typedef NSUInteger MMBezelScaleDirection;


#endif
