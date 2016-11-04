//
//  MMTrashButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMDarkSidebarButton.h"


@interface MMTrashButton : MMDarkSidebarButton

+ (void)drawTrashCanInRect:(CGRect)frame withColor:(UIColor*)strokeColor withBackground:(UIColor*)backgroundColor;

@end
