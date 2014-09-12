//
//  MMCloudKitNoAccountHelpView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/12/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitNoAccountHelpView.h"
#import "UIView+Animations.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMCloudKitNoAccountHelpView{
    CAShapeLayer* topArrow;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){

        UIColor* borderColor = [UIColor colorWithRed: 0.221 green: 0.221 blue: 0.219 alpha: 1];
        UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.503];

        CGFloat width = frame.size.width;
        CGRect lineRect = CGRectMake(width*0.1, kWidthOfSidebarButtonBuffer, width*0.8, 1);
        UIView* line = [[UIView alloc] initWithFrame:lineRect];
        line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        [self addSubview:line];

        
        UIImage* settingsIcon = [UIImage imageNamed:@"ios-settings-icon"];
        UIButton* settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, settingsIcon.size.width, settingsIcon.size.height)];
        [settingsButton setImage:settingsIcon forState:UIControlStateNormal];
        [settingsButton setAdjustsImageWhenHighlighted:NO];
        settingsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        settingsButton.center = CGPointMake(self.bounds.size.width/2, 40 + settingsButton.bounds.size.height/2);
        [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingsButton];
        
        topArrow = [CAShapeLayer layer];
        topArrow.bounds = CGRectMake(0, 0, 80, 80);
        topArrow.path = [self arrowPathForFrame:topArrow.bounds].CGPath;
        topArrow.lineWidth = 1;
        topArrow.strokeColor = borderColor.CGColor;
        topArrow.fillColor = halfWhite.CGColor;
        topArrow.position = CGPointMake(self.bounds.size.width/2, 164);
        
        
        UIImageView* iCloudSettings = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iCloudSettings"]];
        iCloudSettings.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        iCloudSettings.center = CGPointMake(self.bounds.size.width/2, 238);
        [self addSubview:iCloudSettings];
        
        [self.layer addSublayer:topArrow];
        
    }
    return self;
}

-(void) settingsButtonTapped:(UIButton*)button{
    [button bounceWithTransform:CGAffineTransformIdentity stepOne:.2 stepTwo:-.2];
    [[NSThread mainThread] performBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } afterDelay:.2];
}

-(void) layoutSubviews{
    topArrow.position = CGPointMake(self.bounds.size.width/2, topArrow.position.y);
}


-(UIBezierPath*) arrowPathForFrame:(CGRect)frame{
    UIBezierPath* arrowPath = UIBezierPath.bezierPath;
    [arrowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17090 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44944 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81646 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82911 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18354 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44944 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17090 * CGRectGetHeight(frame))];
    [arrowPath closePath];
    return arrowPath;
}

-(void) animateIntoView{
    if(self.hidden){
        self.alpha = 0;
        self.hidden = NO;
        CGRect origFr = self.frame;
        self.frame = CGRectMake(origFr.origin.x, origFr.origin.y+10, origFr.size.width, origFr.size.height);
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = origFr;
            self.alpha = 1;
        } completion:nil];
    }
}

@end
