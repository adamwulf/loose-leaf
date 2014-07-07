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

+(id) itemForPage:(MMUndoablePaperView*)_page{
    return [[MMUndoRedoStrokeItem alloc] initForPage:_page];
}

-(id) initForPage:(MMUndoablePaperView*)_page{
    __weak MMUndoablePaperView* weakPage = _page;
    if(self = [super initWithUndoBlock:^{
        [weakPage undo];
    } andRedoBlock:^{
        [weakPage redo];
    } forPage:_page]){
        // noop
    };

    return self;
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class", [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    if(self = [self initForPage:_page]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return @"[MMUndoRedoStrokeItem]";
}

@end
