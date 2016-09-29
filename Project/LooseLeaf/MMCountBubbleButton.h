//
//  MMCountBubbleButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"


@interface MMCountBubbleButton : MMSidebarButton {
    CGFloat scale;
}

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) CGFloat scale;

// subclasses

- (void)drawCircleBackground:(CGRect)rect;

@end
