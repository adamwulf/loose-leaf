//
//  MMProgressedImageViewButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/7/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageViewButton.h"


@interface MMProgressedImageViewButton : MMImageViewButton

@property (nonatomic, assign) BOOL targetSuccess;
@property (nonatomic, assign) CGFloat targetProgress;

- (void)animateToPercent:(CGFloat)progress success:(BOOL)succeeded completion:(void (^)(BOOL targetSuccess))completion;

@end
