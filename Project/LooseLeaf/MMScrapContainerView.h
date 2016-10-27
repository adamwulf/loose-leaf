//
//  MMScrapContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"

@class MMScrapsOnPaperState;


@interface MMScrapContainerView : MMUntouchableView

- (id)initWithFrame:(CGRect)frame forScrapsOnPaperState:(MMScrapsOnPaperState*)_scrapsOnPaperState;

@end
