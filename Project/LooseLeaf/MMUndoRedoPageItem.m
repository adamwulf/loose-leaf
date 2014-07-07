//
//  MMUndoRedoPageItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"

@implementation MMUndoRedoPageItem

@synthesize page;

+(id) itemWithUndoBlock:(void(^)())undoBlock andRedoBlock:(void(^)())redoBlock forPage:(MMUndoablePaperView*)page{
    return [[MMUndoRedoPageItem alloc] initWithUndoBlock:undoBlock andRedoBlock:redoBlock forPage:page];
}

-(id) initWithUndoBlock:(void (^)())undoBlock andRedoBlock:(void (^)())redoBlock forPage:(MMUndoablePaperView *)_page{
    if(self = [super initWithUndoBlock:undoBlock andRedoBlock:redoBlock]){
        page = _page;
    }
    return self;
}


@end
