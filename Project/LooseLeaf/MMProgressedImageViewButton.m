//
//  MMProgressedImageViewButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/7/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMProgressedImageViewButton.h"
#import "MMOfflineIconView.h"
#import "MMReachabilityManager.h"
#import "NSThread+BlockAdditions.h"

@implementation MMProgressedImageViewButton{
    CGFloat targetProgress;
    BOOL targetSuccess;
    CGFloat lastProgress;
    CGFloat lastRadius;
}

@synthesize targetSuccess;
@synthesize targetProgress;



-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded completion:(void (^)(BOOL targetSuccess))completion{
    targetProgress = progress;
    targetSuccess = succeeded;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGFloat radius = self.drawableFrame.size.width / 2 + 1;
    CAShapeLayer *circle;
    if([self.layer.sublayers count]){
        circle = (CAShapeLayer*)[self.layer.sublayers firstObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
        CAShapeLayer *mask=[CAShapeLayer layer];
        circle.mask = mask;
        [self.layer addSublayer:circle];
    }
    if(radius != lastRadius){
        lastRadius = radius;
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.lineWidth=radius*2;
        ((CAShapeLayer*)circle.mask).path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    }
    
    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        CAShapeLayer *mask2=[CAShapeLayer layer];
        mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        
        UIView* checkOrXView = [[UIView alloc] initWithFrame:self.bounds];
        checkOrXView.backgroundColor = [UIColor whiteColor];
        checkOrXView.layer.mask = mask2;
        
        [[NSThread mainThread] performBlock:^{
            CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
            checkMarkOrXLayer.anchorPoint = CGPointZero;
            checkMarkOrXLayer.bounds = self.bounds;
            UIBezierPath* path = nil;
            if(succeeded){
                path = [UIBezierPath bezierPath];
                CGPoint start = CGPointMake(28, 39);
                CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
                CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
                [path moveToPoint:start];
                [path addLineToPoint:corner];
                [path addLineToPoint:end];
            }else if([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
                path = [UIBezierPath bezierPath];
                CGFloat size = 14;
                CGPoint start = CGPointMake(31, 31);
                CGPoint end = CGPointMake(start.x + size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
                start = CGPointMake(start.x + size, start.y);
                end = CGPointMake(start.x - size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
            }else{
                CGRect iconFrame = CGRectInset(self.drawableFrame, 6, 6);
                iconFrame.origin.y += 4;
                MMOfflineIconView* offlineIcon = [[MMOfflineIconView alloc] initWithFrame:iconFrame];
                offlineIcon.shouldDrawOpaque = YES;
                [checkOrXView addSubview:offlineIcon];
            }
            
            if(path){
                checkMarkOrXLayer.path = path.CGPath;
                checkMarkOrXLayer.strokeColor = [UIColor blackColor].CGColor;
                checkMarkOrXLayer.lineWidth = 6;
                checkMarkOrXLayer.lineCap = @"square";
                checkMarkOrXLayer.strokeStart = 0;
                checkMarkOrXLayer.strokeEnd = 1;
                checkMarkOrXLayer.backgroundColor = [UIColor clearColor].CGColor;
                checkMarkOrXLayer.fillColor = [UIColor clearColor].CGColor;
                [checkOrXView.layer addSublayer:checkMarkOrXLayer];
            }
            
            checkOrXView.alpha = 0;
            [self addSubview:checkOrXView];
            [UIView animateWithDuration:.3 animations:^{
                checkOrXView.alpha = 1;
            } completion:^(BOOL finished){
                [[NSThread mainThread] performBlock:^{
                    [checkOrXView.layer insertSublayer:circle atIndex:0];
                    [UIView animateWithDuration:.3 animations:^{
                        checkOrXView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [checkOrXView removeFromSuperview];
                        [circle removeAnimationForKey:@"drawCircleAnimation"];
                        [circle removeFromSuperlayer];
                        // reset state
                        if(completion) completion(targetSuccess);
                        lastProgress = 0;
                        targetSuccess = 0;
                        targetProgress = 0;
                        lastRadius = 0;
                    }];
                } afterDelay:1];
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess completion:completion];
        } afterDelay:.03];
    }
}

@end
