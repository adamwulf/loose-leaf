//
//  MMScrapBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScrapBackgroundView : UIView{
    CGFloat backgroundRotation;
}

@property (nonatomic, readonly) UIImageView* backingContentView;
@property (nonatomic, assign) CGFloat backgroundRotation;

@end
