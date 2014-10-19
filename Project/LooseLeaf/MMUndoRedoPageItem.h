//
//  MMUndoRedoPageItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoBlockItem.h"
#import "MMPageUndoRedoManager.h"
#import "MMScrapsOnPaperState.h"

@interface MMUndoRedoPageItem : MMUndoRedoBlockItem{
    @protected
    __weak MMUndoablePaperView* page;
}

@property (readonly) MMUndoablePaperView* page;
@property (readonly) MMPageUndoRedoManager* undoRedoManager;

+(id) itemWithUndoBlock:(void(^)())undoBlock andRedoBlock:(void(^)())redoBlock forPage:(MMUndoablePaperView*)page;

- (id) initWithUndoBlock:(void(^)())undoBlock andRedoBlock:(void(^)())redoBlock forPage:(MMUndoablePaperView*)page;

-(BOOL) containsScrapUUID:(NSString*)scrapUUID;

@end
