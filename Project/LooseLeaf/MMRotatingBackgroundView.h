//
//  MMRotatingBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRotatingBackgroundViewDelegate.h"


@interface MMRotatingBackgroundView : UIView

@property (nonatomic, weak) NSObject<MMRotatingBackgroundViewDelegate>* delegate;

- (UIColor*)colorFromPoint:(CGPoint)point;

@end
