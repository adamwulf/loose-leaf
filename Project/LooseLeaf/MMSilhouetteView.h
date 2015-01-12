//
//  MMSilhouetteView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchDotGestureRecognizerDelegate.h"

@interface MMSilhouetteView : UIView<MMTouchDotGestureRecognizerDelegate>


-(void) moveHandToTouch:(UITouch*)touch;

@end
