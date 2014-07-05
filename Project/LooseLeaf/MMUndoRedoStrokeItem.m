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


@implementation MMUndoRedoStrokeItem{
    __weak MMUndoablePaperView* page;
}

+(id) itemForPage:(MMUndoablePaperView*)_page{
    return [[MMUndoRedoStrokeItem alloc] initForPage:_page];
}

-(id) initForPage:(MMUndoablePaperView*)_page{
    __weak MMUndoablePaperView* weakPage = _page;
    if(self = [super initWithUndoBlock:^{
        [weakPage undo];
    } andRedoBlock:^{
        [weakPage redo];
    }]){
        // noop
        page = _page;
    };
    return self;
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionaryWithObject:NSStringFromClass([self class]) forKey:@"class"];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    return [[MMUndoRedoStrokeItem alloc] initForPage:_page];
}

@end
