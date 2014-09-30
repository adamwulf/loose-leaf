//
//  MMScissorResult.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMScissorResult : NSObject

@property (nonatomic, readonly) NSArray* addedScraps;
@property (nonatomic, readonly) NSArray* removedScraps;
@property (nonatomic, readonly) NSArray* removedScrapProperties;
@property (nonatomic, readonly) BOOL didAddFillStroke;

-(id) initWithAddedScraps:(NSArray*)_added andRemovedScraps:(NSArray*)_removed andRemovedScrapProperties:(NSArray*)_removedProps andDidFillStroke:(BOOL)_didFill;

@end
