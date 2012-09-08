//
//  PaintView.h
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PaintTouchViewDelegate.h"

@interface PaintTouchView : UIView {
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    CGFloat fingerWidth;
    
    NSObject<PaintTouchViewDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<PaintTouchViewDelegate>* delegate;


@end
