//
//  MMUndoRedoAddScrapFromBezelItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"


@interface MMUndoRedoAddScrapFromBezelItem : MMUndoRedoPageItem

@property (readonly) NSString* scrapUUID;

+ (id)itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties;

- (id)initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties;

@end
