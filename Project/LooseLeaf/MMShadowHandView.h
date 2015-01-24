//
//  MMSilhouetteView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchDotGestureRecognizerDelegate.h"
#import "MMPaperView.h"

@interface MMShadowHandView : UIView

// bezel
-(void) startBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;
-(void) continueBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;
-(void) endBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;

// panning a page
-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches;
-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches;
-(void) endPanningObject:(id)obj;

// drawing
-(void) startDrawingAtTouch:(UITouch*)touch;
-(void) continueDrawingAtTouch:(UITouch*)touch;
-(void) endDrawingAtTouch:(UITouch*)touch;

@end
