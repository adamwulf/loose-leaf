//
//  MMShareButton.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"


@interface MMShareButton : MMSidebarButton

@property (nonatomic) UIColor* arrowColor;
@property (nonatomic) UIColor* topBgColor;
@property (nonatomic) UIColor* bottomBgColor;
@property (nonatomic, assign, getter=isGreyscale) BOOL greyscale;

@end
