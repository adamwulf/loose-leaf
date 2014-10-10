//
//  MMTracker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMStatTracker : NSObject

+(MMStatTracker*) trackerWithName:(NSString*)name;

+(MMStatTracker*) trackerWithName:(NSString *)name andTargetCount:(NSInteger)targetCount;

- (instancetype)init NS_UNAVAILABLE;

- (void) trackValue:(CGFloat)nextVal;

@end
