//
//  MMRotatingBackgroundViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMRotatingBackgroundView;

@protocol MMRotatingBackgroundViewDelegate <NSObject>

- (void)rotatingBackgroundViewDidUpdate:(MMRotatingBackgroundView*)backgroundView;

@end
