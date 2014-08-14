//
//  MMShareView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"
#import "MMShareManagerDelegate.h"


@interface MMShareView : UIView<MMShareManagerDelegate>

@property (nonatomic) CGFloat buttonWidth;

@end
