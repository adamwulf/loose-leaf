//
//  MMSilhouetteView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchDotGestureRecognizerDelegate.h"

@interface MMSilhouetteView : UIView

-(void) startDrawingAtTouch:(UITouch*)touch;
-(void) continueDrawingAtTouch:(UITouch*)touch;
-(void) endDrawingAtTouch:(UITouch*)touch;

@end
