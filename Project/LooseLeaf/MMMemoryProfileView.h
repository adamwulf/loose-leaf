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
#import "MMMemoryManager.h"


@interface MMMemoryProfileView : MMUntouchableView

@property (weak) MMMemoryManager* memoryManager;

@end
