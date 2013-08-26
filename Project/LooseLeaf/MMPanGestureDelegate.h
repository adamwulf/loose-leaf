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

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture;

@end
