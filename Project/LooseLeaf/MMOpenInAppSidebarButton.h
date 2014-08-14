//
//  MMOpenInAppSidebarButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"
#import "MMShareViewDelegate.h"

@interface MMOpenInAppSidebarButton : MMSidebarButton

@property (nonatomic) NSIndexPath* indexPath;

- (id)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath*)indexPath;

@end
