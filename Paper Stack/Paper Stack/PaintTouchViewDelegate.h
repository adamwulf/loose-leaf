//
//  PaintTouchViewDelegate.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/8/12.
//
//

#import <Foundation/Foundation.h>

@protocol PaintTouchViewDelegate <NSObject>


-(void) beginPanAt:(CGPoint)point forView:(UIView*)view;
-(void) movePanBy:(CGPoint)delta;
-(void) panComplete;


-(void) drawArcAtStart:(CGPoint)point1
                     end:(CGPoint)point2
           controlPoint1:(CGPoint)ctrl1
           controlPoint2:(CGPoint)ctrl2
          withFingerWidth:(CGFloat)fingerWidth
              fromView:(UIView*)view;

-(void) drawDotAtPoint:(CGPoint)point
       withFingerWidth:(CGFloat)fingerWidth
              fromView:(UIView*)view;

-(void) drawLineAtStart:(CGPoint)start
                    end:(CGPoint)end
        withFingerWidth:(CGFloat)fingerWidth
               fromView:(UIView*)view;

-(BOOL) fullyContainsArcAtStart:(CGPoint)point1
                            end:(CGPoint)point2
                  controlPoint1:(CGPoint)ctrl1
                  controlPoint2:(CGPoint)ctrl2
                withFingerWidth:(CGFloat)fingerWidth
                       fromView:(UIView*)view;

@end
