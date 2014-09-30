//
//  MMPermissionCameraPhotosCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPermissionCameraPhotosCollectionViewCell.h"
#import "UIView+Animations.h"
#import "NSThread+BlockAdditions.h"
#import "UIDevice+PPI.h"
#import "Constants.h"

@implementation MMPermissionCameraPhotosCollectionViewCell{
    CAShapeLayer* topArrow;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        UIColor* borderColor = [UIColor colorWithRed: 0.221 green: 0.221 blue: 0.219 alpha: 1];
        UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.503];
        
        UIImage* settingsIcon = [UIImage imageNamed:@"ios-settings-icon"];
        UIButton* settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, settingsIcon.size.width, settingsIcon.size.height)];
        [settingsButton setImage:settingsIcon forState:UIControlStateNormal];
        [settingsButton setAdjustsImageWhenHighlighted:NO];
        settingsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        settingsButton.center = CGPointMake(self.bounds.size.width/2, 30 + settingsButton.bounds.size.height/2);
        [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingsButton];
        
        topArrow = [CAShapeLayer layer];
        topArrow.bounds = CGRectMake(0, 0, 80, 80);
        topArrow.path = [self arrowPathForFrame:topArrow.bounds].CGPath;
        topArrow.lineWidth = 1;
        topArrow.strokeColor = borderColor.CGColor;
        topArrow.fillColor = halfWhite.CGColor;
        topArrow.position = CGPointMake(self.bounds.size.width/2, 148);
        [self.layer addSublayer:topArrow];
        
        UIImageView* settingsPrivacy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-privacy"]];
        settingsPrivacy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        settingsPrivacy.center = CGPointMake(self.bounds.size.width/2, 216);
        [self addSubview:settingsPrivacy];
        
        CAShapeLayer* midArrow = [CAShapeLayer layer];
        midArrow.bounds = CGRectMake(0, 0, 80, 80);
        midArrow.path = [self arrowPathForFrame:midArrow.bounds].CGPath;
        midArrow.lineWidth = 1;
        midArrow.strokeColor = borderColor.CGColor;
        midArrow.fillColor = halfWhite.CGColor;
        midArrow.position = CGPointMake(self.bounds.size.width/2, 274);
        [self.layer addSublayer:midArrow];
        
        NSString* settingsStep2Image;
        if([UIDevice majorVersion] >= 8){
            settingsStep2Image = @"ios8-settings-photos";
        }else{
            settingsStep2Image = @"ios7-settings-photos";
        }
        UIImageView* settingsCamera = [[UIImageView alloc] initWithImage:[UIImage imageNamed:settingsStep2Image]];
        settingsCamera.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        settingsCamera.center = CGPointMake(self.bounds.size.width/2, 338);
        [self addSubview:settingsCamera];
        
        NSString* settingsStep2Image2;
        if([UIDevice majorVersion] >= 8){
            settingsStep2Image2 = @"ios8-settings-camera";
        }else{
            settingsStep2Image2 = @"ios7-settings-camera";
        }
        UIImageView* settingsPhotos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:settingsStep2Image2]];
        settingsPhotos.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        settingsPhotos.center = CGPointMake(self.bounds.size.width/2, 388);
        [self addSubview:settingsPhotos];
        
        if([UIDevice majorVersion] < 8){
            CAShapeLayer* lastArrow = [CAShapeLayer layer];
            lastArrow.bounds = CGRectMake(0, 0, 80, 80);
            lastArrow.path = [self arrowPathForFrame:lastArrow.bounds].CGPath;
            lastArrow.lineWidth = 1;
            lastArrow.strokeColor = borderColor.CGColor;
            lastArrow.fillColor = halfWhite.CGColor;
            lastArrow.position = CGPointMake(self.bounds.size.width/2, 396);
            [self.layer addSublayer:lastArrow];
            
            UIImageView* settingsPermission = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CloudKitPermissionSwitch"]];
            settingsPermission.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            settingsPermission.center = CGPointMake(self.bounds.size.width/2, 454);
            [self addSubview:settingsPermission];
        }
    }
    return self;
}

+(CGFloat) idealPhotoRowHeight{
    if([UIDevice majorVersion] >= 8){
        return 2.5;
    }else{
        return 3.25;
    }
}

-(void) settingsButtonTapped:(UIButton*)button{
    if([UIDevice majorVersion] >= 8){
        [button bounceWithTransform:CGAffineTransformIdentity stepOne:.2 stepTwo:-.2];
        [[NSThread mainThread] performBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } afterDelay:.2];
    }
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



@end
