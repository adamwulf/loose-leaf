//
//  SLPanGestureRecognizerDelegate.h
//  PaintingSample
//
//  Created by Adam Wulf on 11/1/12.
//
//

#import <Foundation/Foundation.h>

@protocol SLPanGestureRecognizerDelegate <NSObject>

-(UIView*) objectAtPointOnPage:(CGPoint) point;

@end
