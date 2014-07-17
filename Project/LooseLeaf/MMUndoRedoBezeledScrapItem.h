//
//  MMUndoRedoBezeledItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"

@interface MMUndoRedoBezeledScrapItem : MMUndoRedoPageItem

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap andProperties:(NSDictionary*)scrapProperties;

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap andProperties:(NSDictionary*)scrapProperties;

@end
