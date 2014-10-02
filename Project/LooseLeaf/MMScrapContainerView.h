//
//  MMScrapContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"

@class MMScrappedPaperView;

@interface MMScrapContainerView : MMUntouchableView

- (id)initWithFrame:(CGRect)frame forPageDelegate:(MMScrappedPaperView*)page;

@end
