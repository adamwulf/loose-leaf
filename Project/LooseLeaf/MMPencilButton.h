//
//  MMPencilButton.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"

@class MMPencilTool;

@interface MMPencilButton : MMSidebarButton

@property (weak) MMPencilTool* tool;

@end
