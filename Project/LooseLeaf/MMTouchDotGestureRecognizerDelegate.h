//
//  MMTouchDotGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMTouchDotGestureRecognizerDelegate <NSObject>

-(void) dotTouchesBegan:(NSSet *)touches;

-(void) dotTouchesMoved:(NSSet *)touches;

-(void) dotTouchesEnded:(NSSet *)touches;

-(void) dotTouchesCancelled:(NSSet *)touches;

@end
