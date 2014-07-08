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
    NSArray* removedScrapProperties;
    BOOL didAddFillStroke;
}

@synthesize addedScraps;
@synthesize removedScraps;
@synthesize removedScrapProperties;
@synthesize didAddFillStroke;

-(id) initWithAddedScraps:(NSArray*)_added andRemovedScraps:(NSArray*)_removed andRemovedScrapProperties:(NSArray*)_removedProps andDidFillStroke:(BOOL)_didFill{
    if(self = [super init]){
        if([_removed count] != [_removedProps count]){
            @throw [NSException exceptionWithName:@"InvalidArgumentsException" reason:@"number of scraps and scrap properties must match" userInfo:nil];
        }
        addedScraps = _added;
        removedScraps = _removed;
        removedScrapProperties = _removedProps;
        didAddFillStroke = _didFill;
    }
    return self;
}

@end
