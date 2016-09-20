//
//  MMRulerAdjustment.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMRulerAdjustment : NSObject

@property (nonatomic, readonly) NSArray* elements;
@property (nonatomic, readonly) BOOL didAdjust;

- (id)__unavailable init;

- (id)initWithAdjustments:(NSArray*)elements andDidAdjust:(BOOL)adjust;

@end
