//
//  MMUndoRedoStrokeItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"
#import "MMPageUndoRedoManager.h"

@class MMUndoablePaperView;

@interface MMUndoRedoStrokeItem : MMUndoRedoPageItem

+(id) itemForPage:(MMUndoablePaperView*)_page withUndoManager:(MMPageUndoRedoManager*)undoManager;

-(id) initForPage:(MMUndoablePaperView*)page withUndoManager:(MMPageUndoRedoManager*)undoManager;

@end
