//
//  MMRulerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMRulerView : UIView

-(void) updateLineAt:(CGPoint)p1 to:(CGPoint)p2 startingDistance:(CGFloat)distance;

-(void) liftRuler;

-(NSArray*) willAddElementsToStroke:(NSArray *)elements;

-(void) willBeginStrokeAt:(CGPoint)point;

@end
