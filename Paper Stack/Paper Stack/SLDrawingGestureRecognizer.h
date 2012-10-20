//
//  SLDrawingGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 10/20/12.
//
//

#import <UIKit/UIKit.h>
#import "SLDrawingGestureRecognizerDelegate.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLDrawingGestureRecognizer : UIPanGestureRecognizer{
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    CGFloat fingerWidth;

    NSObject<SLDrawingGestureRecognizerDelegate>* paintDelegate;
}

@property (nonatomic, assign) NSObject<SLDrawingGestureRecognizerDelegate>* paintDelegate;

@end
