//
//  Contants.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#ifndef Paper_Stack_Contants_h
#define Paper_Stack_Contants_h


#ifdef __cplusplus
extern "C" {
#endif

    
#ifdef DEBUG
    //#define DebugLog(__FORMAT__, ...)
#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ## __VA_ARGS__)
#else
#define DebugLog(__FORMAT__, ...)
#endif

    extern CGFloat SSDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

    extern CGFloat SSSquaredDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

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
