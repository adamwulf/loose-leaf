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
#import "PaintableViewDelegate.h"

@interface PaintView : UIView<PaintTouchViewDelegate> {
    void *cacheBitmap;
    CGContextRef cacheContext;
    CGFloat hue;
    NSObject<PaintableViewDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<PaintableViewDelegate>* delegate;

@property (nonatomic, readonly) UIBezierPath* clipPath;

@end
