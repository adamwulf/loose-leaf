//
//  MMUndoRedoStrokeItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"

@class MMUndoablePaperView;

@interface MMUndoRedoStrokeItem : MMUndoRedoPageItem

+(id) itemForPage:(MMUndoablePaperView*)_page;

-(id) initForPage:(MMUndoablePaperView*)page;

@end
