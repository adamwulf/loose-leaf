//
//  MMCloudKitExportAnimationView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportView.h"
#import "MMUntouchableView.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMCloudKitExportView

#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [self addSubview:avatarButton];
    
    CGFloat duration = .8;
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        CGPoint originalCenter = avatarButton.center;
        CGPoint targetCenter = CGPointMake(200 + avatarButton.bounds.size.width/2, avatarButton.bounds.size.height/2);
        
        
        int firstDrop = 14;
        int topOfBounce = 18;
        int maxSteps = 20;
        CGFloat bounceHeight = 25;
        
        for (int foo = 1; foo <= maxSteps; foo += 1) {
            NSLog(@"animation starting at: %f for %f", (foo-1)/(float)maxSteps, 1/(float)maxSteps);
            [UIView addKeyframeWithRelativeStartTime:((foo-1)/(float)maxSteps) relativeDuration:1/(float)maxSteps animations:^{
                CGFloat x;
                CGFloat y;
                CGFloat t;
                if(foo <= firstDrop){
                    t = foo/(float)firstDrop;
                    x = logTransform(originalCenter.x, targetCenter.x, t);
                    y = sqTransform(originalCenter.y, targetCenter.y, t);
                    NSLog(@"1keyframe to %f %f %f => %d", x, y, t, foo);
                }else if(foo <= topOfBounce){
                    // 7, 8
                    t = (foo-firstDrop)/(float)(topOfBounce - firstDrop);
                    x = targetCenter.x;
                    y = sqrtTransform(targetCenter.y, targetCenter.y + bounceHeight, t);
                    NSLog(@"2keyframe to %f %f %f => %d", x, y, t, foo);
                }else{
                    // 9
                    t = (foo-topOfBounce) / (float)(maxSteps - topOfBounce);
                    x = targetCenter.x;
                    y = sqTransform(targetCenter.y + bounceHeight, targetCenter.y, t);
                    NSLog(@"3keyframe to %f %f %f => %d", x, y, t, foo);
                }
                
                avatarButton.center = CGPointMake(x, y);
            }];
        }
        
    } completion:^(BOOL finished) {
        [[NSThread mainThread] performBlock:^{
            [avatarButton removeFromSuperview];
        } afterDelay:5];
    }];
}

@end
