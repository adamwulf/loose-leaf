//
//  MMUndoRedoMoveScrapItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/7/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"
#import "MMScrapView.h"


@interface MMUndoRedoMoveScrapItem : MMUndoRedoPageItem

@property (readonly) NSString* scrapUUID;

+ (id)itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID from:(NSDictionary*)startProperties to:(NSDictionary*)endProperties;

- (id)initForPage:(MMUndoablePaperView*)page andScrapUUID:(NSString*)scrapUUID from:(NSDictionary*)startProperties to:(NSDictionary*)endProperties;


@end
