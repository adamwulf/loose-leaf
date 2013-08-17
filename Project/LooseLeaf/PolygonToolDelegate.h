//
//  PolygonToolDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/16/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PolygonToolDelegate <NSObject>

-(void) beginShapeWithTouch:(UITouch*)touch;

-(void) continueShapeWithTouch:(UITouch*)touch;

-(void) finishShapeWithTouch:(UITouch*)touch;

-(void) cancelShapeWithTouch:(UITouch*)touch;

@end
