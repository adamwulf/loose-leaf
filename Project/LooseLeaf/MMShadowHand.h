//
//  MMShadowHand.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/19/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMShadowHand : NSObject

@property (readonly) CALayer* layer;
@property (strong) id relatedObject;

-(id) initForRightHand:(BOOL)isRight forView:(UIView*)relativeView;

// panning a page
-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches;
-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches;
-(void) endPanningObject:(id)obj;

// drawing
-(void) startDrawingAtTouch:(UITouch*)touch;
-(void) continueDrawingAtTouch:(UITouch*)touch;
-(void) endDrawingAtTouch:(UITouch*)touch;

@end
