//
//  MMScissorResult.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScissorResult.h"

@implementation MMScissorResult{
    NSArray* addedScraps;
    NSArray* removedScraps;
    BOOL didAddFillStroke;
}

@synthesize addedScraps;
@synthesize removedScraps;
@synthesize didAddFillStroke;

-(id) initWithAddedScraps:(NSArray*)_added andRemovedScraps:(NSArray*)_removed andDidFillStroke:(BOOL)_didFill{
    if(self = [super init]){
        addedScraps = _added;
        removedScraps = _removed;
        didAddFillStroke = _didFill;
    }
    return self;
}

@end
