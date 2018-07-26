//
//  MMColorButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"


@interface MMColorButton : MMSidebarButton

@property (nonatomic) UIColor* color;
@property (nonatomic) CGRect originalFrame;

- (id)init NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithCoder:(NSCoder*)aDecoder NS_UNAVAILABLE;
- (id)initWithColor:(UIColor*)color andFrame:(CGRect)frame;

@end
