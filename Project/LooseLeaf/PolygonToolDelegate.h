//
//  PolygonToolDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/16/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PolygonTool;

@protocol PolygonToolDelegate <NSObject>

-(void) beginShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool;

-(void) continueShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool;

-(void) finishShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool;

-(void) cancelShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool;

@end
