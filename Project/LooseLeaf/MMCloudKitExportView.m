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

@implementation MMCloudKitExportView

-(CGFloat) sqrtTransform:(CGFloat)min max:(CGFloat)max t:(CGFloat)t{
    t = sqrt(t);
    return min + (max - min)*t;
}

-(CGFloat) sqTransform:(CGFloat)min max:(CGFloat)max t:(CGFloat)t{
    t = t*t;
    return min + (max - min)*t;
}


#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [self addSubview:avatarButton];
    
    [UIView animateKeyframesWithDuration:3.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        
        CGPoint originalCenter = avatarButton.center;
        CGPoint targetCenter = CGPointMake(100 + avatarButton.bounds.size.width/2, avatarButton.bounds.size.height/2);
        CGPoint diff = CGPointMake(targetCenter.x - originalCenter.x, targetCenter.y - originalCenter.y);
        
        for (int foo = 0; foo < 10; foo += 1) {
            [UIView addKeyframeWithRelativeStartTime:(foo/10.0) relativeDuration:0.1 animations:^{
                
                CGFloat x = [self sqrtTransform:originalCenter.x max:originalCenter.x + diff.x t:((foo+1)/10.0)];
                CGFloat y = [self sqTransform:originalCenter.y max:originalCenter.y + diff.y t:((foo+1)/10.0)];
                
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
