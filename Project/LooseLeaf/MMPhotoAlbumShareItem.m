//
//  MMPhotoAlbumShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbumShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MMPhotoAlbumShareItem{
    MMImageViewButton* button;
    
    CGFloat targetProgress;
    BOOL targetSuccess;
    CGFloat lastProgress;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"photoalbum"]];
        
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
    [delegate mayShare:self];
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            UIImage* image = self.delegate.imageToShare;
            [self animateToPercent:.7 completion:^(BOOL didSucceed) {
                if(didSucceed){
                    [self.delegate didShare:self];
                }
            }];
            [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                NSString* strResult = @"Failed";
                [self updateButtonGreyscale];
                if (error) {
                    targetSuccess = NO;
                    targetProgress = 1.0;
                } else {
                    strResult = @"Success";
                    targetSuccess = YES;
                    targetProgress = 1.0;
                    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
                }
                [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"PhotoAlbum",
                                                                             kMPEventExportPropResult : strResult}];
            }];
        }
    });
}

-(void) animateToPercent:(CGFloat)progress completion:(void (^)(BOOL targetSuccess))completion{
    targetProgress = progress;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }
    
    CGPoint center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
    
    CGFloat radius = button.drawableFrame.size.width / 2 - 1;
    CAShapeLayer *circle;
    if([button.layer.sublayers count]){
        circle = [button.layer.sublayers firstObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
        CAShapeLayer *mask=[CAShapeLayer layer];
        circle.mask = mask;
        [button.layer addSublayer:circle];
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.lineWidth=radius*2;
        ((CAShapeLayer*)circle.mask).path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    }
    
    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        CAShapeLayer *mask2=[CAShapeLayer layer];
        mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        
        UIView* checkOrXView = [[UIView alloc] initWithFrame:button.bounds];
        checkOrXView.backgroundColor = [UIColor whiteColor];
        checkOrXView.layer.mask = mask2;
        
        [[NSThread mainThread] performBlock:^{
            CGRect drawableFrame = button.drawableFrame;
            CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
            checkMarkOrXLayer.anchorPoint = CGPointZero;
            checkMarkOrXLayer.bounds = button.bounds;
            UIBezierPath* path = [UIBezierPath bezierPath];
            if(targetSuccess){
                CGPoint start = CGPointMake(drawableFrame.origin.x + (drawableFrame.size.width - 20)/2,drawableFrame.origin.y + (drawableFrame.size.height - 14)/2 + 8);
                CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
                CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
                [path moveToPoint:start];
                [path addLineToPoint:corner];
                [path addLineToPoint:end];
            }else{
                CGFloat size = 14;
                CGPoint start = CGPointMake(drawableFrame.origin.x + (drawableFrame.size.width - size)/2,drawableFrame.origin.y + (drawableFrame.size.height - size)/2);
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
                if(completion) completion(targetSuccess);
                [[NSThread mainThread] performBlock:^{
                    [checkOrXView removeFromSuperview];
                    [circle removeAnimationForKey:@"drawCircleAnimation"];
                    [circle removeFromSuperlayer];
                    // reset state
                    lastProgress = 0;
                    targetSuccess = 0;
                    targetProgress = 0;
                } afterDelay:.5];
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress completion:completion];
        } afterDelay:.03];
    }
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
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
