//
//  MMPencilTool.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMColorButton.h"
#import "MMPencilButton.h"
#import "MMSidebarButtonDelegate.h"

@interface MMPencilTool : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic) NSObject<MMSidebarButtonDelegate>* delegate;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
