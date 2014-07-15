//
//  MMUndoRedoPageItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"
#import "MMPageUndoRedoManager.h"

@implementation MMUndoRedoPageItem{
    __weak MMPageUndoRedoManager* undoRedoManager;
}

@synthesize page;
@synthesize undoRedoManager;

+(id) itemWithUndoBlock:(void(^)())undoBlock andRedoBlock:(void(^)())redoBlock forPage:(MMUndoablePaperView*)page withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoPageItem alloc] initWithUndoBlock:undoBlock andRedoBlock:redoBlock forPage:page withUndoManager:(MMPageUndoRedoManager*)undoManager];
}

-(id) initWithUndoBlock:(void (^)())undoBlock andRedoBlock:(void (^)())redoBlock forPage:(MMUndoablePaperView *)_page withUndoManager:(MMPageUndoRedoManager*)_undoManager{
    if(self = [super initWithUndoBlock:undoBlock andRedoBlock:redoBlock]){
        undoRedoManager = _undoManager;
        page = _page;
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@]", NSStringFromClass([self class])];
}


@end
