//
//  MMDebugStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"

@class MMLooseLeafViewController;


@interface MMDebugStackView : MMUntouchableView

+ (MMDebugStackView*)sharedView;

@property (nonatomic, strong) MMLooseLeafViewController* llvc;

@end
