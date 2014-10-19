//
//  MMEmptyCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEmptyCollectionViewCell.h"
#import "MMPolaroidView.h"
#import "MMPolaroidsView.h"
#import "UIView+Debug.h"
#import "MMRotationManager.h"



@implementation MMEmptyCollectionViewCell{
    MMPolaroidsView* icon;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        icon = [[MMPolaroidsView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, 140)];
        icon.backgroundColor = [UIColor clearColor];
        [self addSubview:icon];
    }
    return self;
}

#pragma mark - Rotation

-(CGFloat) sidebarButtonRotation{
    if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait){
        return 0;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft){
        return -M_PI_2;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight){
        return M_PI_2;
    }else{
        return M_PI;
    }
}

-(void) updatePhotoRotation:(BOOL)animated{
    if(animated){
        [UIView animateWithDuration:.2 animations:^{
            icon.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        }];
    }else{
        icon.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
    }
}

@end
