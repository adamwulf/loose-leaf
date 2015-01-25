//
//  Contants.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#ifndef Paper_Stack_Contants_h
#define Paper_Stack_Contants_h

#define DebugLog NSLog

#ifdef __cplusplus
extern "C" {
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
