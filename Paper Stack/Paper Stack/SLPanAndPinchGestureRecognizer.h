//
//  SLPanGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLPanAndPinchGestureRecognizer : UIPanGestureRecognizer{
    CGFloat initialDistance;
    CGFloat scale;
}

@property (nonatomic, readonly) CGFloat scale;

@end
