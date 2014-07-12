//
//  MMUndoRedoStrokeItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoStrokeItem.h"
#import "MMUndoablePaperView.h"
#import "MMEditablePaperView+UndoRedo.h"


@implementation MMUndoRedoStrokeItem

+(id) itemForPage:(MMUndoablePaperView*)_page withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoStrokeItem alloc] initForPage:_page withUndoManager:(MMPageUndoRedoManager*)undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page withUndoManager:(MMPageUndoRedoManager*)undoManager{
    __weak MMUndoablePaperView* weakPage = _page;
    if(self = [super initWithUndoBlock:^{
        [weakPage undo];
    } andRedoBlock:^{
        [weakPage redo];
    } forPage:_page withUndoManager:undoManager]){
        // noop
    };

    return self;
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class", [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoManager{
    if(self = [self initForPage:_page withUndoManager:(MMPageUndoRedoManager*)undoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return @"[MMUndoRedoStrokeItem]";
}

@end
