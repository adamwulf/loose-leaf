//
//  MMTouchDotGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMTouchDotGestureRecognizerDelegate <NSObject>

-(void) touchesBegan:(NSSet *)touches;

-(void) touchesMoved:(NSSet *)touches;

-(void) touchesEnded:(NSSet *)touches;

-(void) touchesCancelled:(NSSet *)touches;

@end
