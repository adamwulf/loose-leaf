//
//  SLDrawingGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 10/20/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLDrawingGestureRecognizer : UIPanGestureRecognizer{
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    CGFloat fingerWidth;

    CGPoint startPoint;
    CGPathElement pathElement;
}

@property (nonatomic, readonly) CGFloat fingerWidth;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPathElement pathElement;

-(void) cancel;

@end
