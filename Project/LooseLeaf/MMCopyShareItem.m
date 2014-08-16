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

        [self animateToPercent:1.0 success:YES];
    }
}

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded{
    targetProgress = progress;
    targetSuccess = succeeded;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }
    
    CGPoint center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
    
    CGFloat radius = button.drawableFrame.size.width / 2;
    CAShapeLayer *circle;
    if([button.layer.sublayers count]){
        circle = [button.layer.sublayers firstObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[UIColor whiteColor].CGColor;
        circle.lineWidth=radius*2;
        CAShapeLayer *mask=[CAShapeLayer layer];
        mask.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.mask = mask;
        [button.layer addSublayer:circle];
    }
    
    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        UILabel* label = [[UILabel alloc] initWithFrame:button.bounds];
        
        [[NSThread mainThread] performBlock:^{
            if(succeeded){
                label.text = @"\u2714";
            }else{
                label.text = @"\u2718";
            }
            label.font = [UIFont fontWithName:@"ZapfDingbatsITC" size:30];
            label.textAlignment = NSTextAlignmentCenter;
            label.alpha = 0;
            [button addSubview:label];
            [UIView animateWithDuration:.3 animations:^{
                label.alpha = 1;
            } completion:^(BOOL finished){
                [delegate didShare:self];
                [[NSThread mainThread] performBlock:^{
                    [label removeFromSuperview];
                    [circle removeAnimationForKey:@"drawCircleAnimation"];
                    [circle removeFromSuperlayer];
                    
                    lastProgress = 0;
                    targetProgress = 0;
                } afterDelay:.5];
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess];
        } afterDelay:.03];
    }
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
