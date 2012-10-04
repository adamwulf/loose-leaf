//
//  PaintingSampleViewController.h
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintableImageView.h"
#import "PaintView.h"
#import "PaintTouchView.h"
#import "PaintableImageView.h"
#import "PaintTouchViewDelegate.h"
#import "PaintableViewDelegate.h"

@interface PaintingSampleViewController : UIViewController<PaintTouchViewDelegate,PaintableViewDelegate>{
    UIView* container;
    NSTimer* timer;
    
    UISwitch* _switch;
    
    PaintView* canvas;
    PaintableImageView* mars1;
    PaintableImageView* mars2;
    PaintableImageView* mars3;
    
    
    PaintTouchView *paintTouch;
}

@end
