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

- (id)initWithColor:(UIColor*)color andFrame:(CGRect)frame;

@end
