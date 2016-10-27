//
//  MMStopWatch.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMStopWatch : NSObject

- (id)initWithDuration:(CGFloat)duration;

- (BOOL)isRunning;

- (void)start;

- (CGFloat)stop;

- (CGFloat)read;

@end
