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
#define MIXPANEL_TOKEN @"YOUR_DEBUG_MIXPANEL_TOKEN"
#else
#define MIXPANEL_TOKEN @"YOUR_PROD_MIXPANEL_TOKEN"
#endif


#ifdef DEBUG
#define debug_NSLog(__FORMAT__, ...)
//#define debug_NSLog(__FORMAT__, ...) NSLog(__FORMAT__, ## __VA_ARGS__)
#else
#define debug_NSLog(__FORMAT__, ...)
#endif

#define SIGN(__var__) (__var__ / ABS(__var__))

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

#define kTestflightAppToken @"7cad2371-d0e0-4524-a833-dbc6cbc7a870"

#define kAnimationDelay 0.05

// Ruler
#define kWidthOfRuler 70
#define kRulerPinchBuffer 40
#define kRulerSnapAngle M_PI / 45.0


// List View
#define kNumberOfColumnsInListView 3
#define kListPageZoom .25

// List View Gesture
#define kZoomToListPageZoom .4
#define kMinPageZoom .8
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

// Scraps
#define kScrapShadowBufferSize 4

// MixPanel
#define kMPDurationAppOpen @"Duration App Open"
#define kMPNumberOfPages @"Number of Pages"
#define kMPFirstLaunchDate @"Date of First Launch"
#define kMPNumberOfScraps @"Number of Scraps"


// photo album
#define kMaxPhotoRotationInDegrees 20

#define RandomPhotoRotation (rand() % kMaxPhotoRotationInDegrees - kMaxPhotoRotationInDegrees/2) / 360.0 * M_PI

#ifdef __cplusplus
extern "C" {
#endif


    CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

    CGFloat SquaredDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

    CGPoint NormalizePointTo(CGPoint point1, CGSize size);
    
    CGPoint DenormalizePointTo(CGPoint point1, CGSize size);
    
    CGPoint AveragePoints(CGPoint point1, CGPoint point2);
    
#ifdef __cplusplus
}
#endif

    
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


#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct Quadrilateral{
        CGPoint upperLeft;
        CGPoint upperRight;
        CGPoint lowerRight;
        CGPoint lowerLeft;
    } Quadrilateral;
    
#ifdef __cplusplus
}  // extern "C"
#endif



#endif
