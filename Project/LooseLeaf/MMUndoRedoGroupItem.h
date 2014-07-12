//
//  MMUndoRedoGroupItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"

@interface MMUndoRedoGroupItem : MMUndoRedoPageItem

+(id) itemForPage:(MMUndoablePaperView*)_page withItems:(NSArray*)undoableItems withUndoManager:(MMPageUndoRedoManager*)undoManager;

-(id) initForPage:(MMUndoablePaperView*)_page withItems:(NSArray*)undoableItems withUndoManager:(MMPageUndoRedoManager*)undoManager;

@end
