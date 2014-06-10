//
//  MMPanGestureDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MMPanGestureDelegate <NSObject>

//
// ownership of touches can only be asked for as long as the Ended or Cancelled
// event for that touch has never been called. a gesture cannot ever take
// ownership of a touch inside of its Ended or Cancelled event.
-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture;

@end
