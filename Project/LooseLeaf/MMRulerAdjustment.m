//
//  MMRulerAdjustment.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerAdjustment.h"

@implementation MMRulerAdjustment{
    NSArray* adjustedElements;
    BOOL didAdjust;
}

-(id) initWithAdjustments:(NSArray*)elements andDidAdjust:(BOOL)adjust{
    if(self = [super init]){
        adjustedElements = elements;
        didAdjust = adjust;
    }
    return self;
}

- (NSArray*) elements{
    return adjustedElements;
}

-(BOOL) didAdjust{
    return didAdjust;
}


@end
