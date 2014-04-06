//
//  MMTouchDotGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMTouchDotGestureRecognizerDelegate <NSObject>

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
