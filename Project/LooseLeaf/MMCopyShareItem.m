//
//  MMCopyShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/16/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCopyShareItem.h"
#import "Mixpanel.h"
#import "NSThread+BlockAdditions.h"
#import "MMImageViewButton.h"
#import "Constants.h"

@implementation MMCopyShareItem{
    CGFloat lastProgress;
    CGFloat targetProgress;
    BOOL targetSuccess;
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"copy"]];
        button.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    if(!targetProgress){
        // only trigger if not already animating
        [delegate mayShare:self];
        
        [UIPasteboard generalPasteboard].image = self.delegate.imageToShare;
        
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Copy To Clipboard",
                                                                     kMPEventExportPropResult : @"Success"}];

        [self animateToSuccess:YES];
    }
}

-(void) animateToSuccess:(BOOL)succeeded{
    CGPoint center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
    if(button.contentScaleFactor == 2){
        center = CGPointMake(button.bounds.size.width/2-.5, button.bounds.size.height/2-.5);
    }
    
    CAShapeLayer *circle=[CAShapeLayer layer];
    CGFloat radius = button.drawableFrame.size.width / 2;
    circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    circle.fillColor=[UIColor clearColor].CGColor;
    circle.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
    circle.lineWidth=radius*2;
    circle.strokeEnd = 0;
    
    
    CAShapeLayer *mask=[CAShapeLayer layer];
    mask.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-1.5 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    
    CAShapeLayer *mask2=[CAShapeLayer layer];
    mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-1.5 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    
    circle.mask = mask;
    
    UIView* checkOrXView = [[UIView alloc] initWithFrame:button.bounds];
    checkOrXView.backgroundColor = [UIColor whiteColor];
    checkOrXView.layer.mask = mask2;
    
    [button.layer addSublayer:circle];
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration=.4;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion=NO;
    animation.fromValue=@(0);
    animation.toValue=@(1);
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [circle addAnimation:animation forKey:@"drawCircleAnimation"];
    
    [[NSThread mainThread] performBlock:^{
        CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
        checkMarkOrXLayer.anchorPoint = CGPointZero;
        checkMarkOrXLayer.bounds = button.bounds;
        UIBezierPath* path = [UIBezierPath bezierPath];
        if(succeeded){
            CGPoint start = CGPointMake(28, 39);
            CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
            CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
            [path moveToPoint:start];
            [path addLineToPoint:corner];
            [path addLineToPoint:end];
        }else{
            CGFloat size = 14;
            CGPoint start = CGPointMake(31, 31);
            CGPoint end = CGPointMake(start.x + size, start.y + size);
            [path moveToPoint:start];
            [path addLineToPoint:end];
            start = CGPointMake(start.x + size, start.y);
            end = CGPointMake(start.x - size, start.y + size);
            [path moveToPoint:start];
            [path addLineToPoint:end];
        }
        checkMarkOrXLayer.path = path.CGPath;
        checkMarkOrXLayer.strokeColor = [UIColor blackColor].CGColor;
        checkMarkOrXLayer.lineWidth = 6;
        checkMarkOrXLayer.lineCap = @"square";
        checkMarkOrXLayer.strokeStart = 0;
        checkMarkOrXLayer.strokeEnd = 1;
        checkMarkOrXLayer.backgroundColor = [UIColor clearColor].CGColor;
        checkMarkOrXLayer.fillColor = [UIColor clearColor].CGColor;
        
        checkOrXView.alpha = 0;
        [checkOrXView.layer addSublayer:checkMarkOrXLayer];
        [button addSubview:checkOrXView];
        [UIView animateWithDuration:.3 animations:^{
            checkOrXView.alpha = 1;
        } completion:^(BOOL finished){
            [delegate didShare:self];
            [[NSThread mainThread] performBlock:^{
                [checkOrXView removeFromSuperview];
                [circle removeAnimationForKey:@"drawCircleAnimation"];
                [circle removeFromSuperlayer];
            } afterDelay:.5];
        }];
    } afterDelay:.3];
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([UIPrintInteractionController isPrintingAvailable]){
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
