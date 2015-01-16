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

@interface MMSilhouetteView : UIView


// panning a page
-(void) startPanningPage:(MMPaperView*)page withTouches:(NSArray*)touches;
-(void) continuePanningPage:(MMPaperView*)page withTouches:(NSArray*)touches;
-(void) endPanningPage:(MMPaperView*)page;

// drawing
-(void) startDrawingAtTouch:(UITouch*)touch;
-(void) continueDrawingAtTouch:(UITouch*)touch;
-(void) endDrawingAtTouch:(UITouch*)touch;

@end
