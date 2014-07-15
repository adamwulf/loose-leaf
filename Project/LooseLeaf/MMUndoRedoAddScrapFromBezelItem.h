//
//  MMUndoRedoAddScrapFromBezelItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"

@interface MMUndoRedoAddScrapFromBezelItem : MMUndoRedoPageItem

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap withUndoManager:(MMPageUndoRedoManager*)undoManager;

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap withUndoManager:(MMPageUndoRedoManager*)undoManager;

@end
