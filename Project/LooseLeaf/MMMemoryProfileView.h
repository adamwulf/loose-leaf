//
//  MMMemoryProfileView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"
#import "MMScrapPaperStackView.h"

@interface MMMemoryProfileView : MMUntouchableView

@property (weak) MMScrapPaperStackView* stackView;

@end
