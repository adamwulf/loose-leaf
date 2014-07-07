//
//  MMUndoRedoGroupItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoGroupItem.h"
#import "NSArray+Map.h"

@implementation MMUndoRedoGroupItem{
    NSArray* undoableItems;
}

+(id) itemForPage:(MMUndoablePaperView *)_page withItems:(NSArray *)undoableItems{
    return [[MMUndoRedoGroupItem alloc] initForPage:_page withItems:undoableItems];
}

-(id) initForPage:(MMUndoablePaperView *)_page withItems:(NSArray *)_undoableItems{
    if(self = [super initWithUndoBlock:^{
        for(NSObject<MMUndoRedoItem>*obj in undoableItems){
            [obj undo];
        }
    } andRedoBlock:^{
        for(NSObject<MMUndoRedoItem>*obj in [undoableItems reverseObjectEnumerator]){
            [obj redo];
        }
    } forPage:_page]){
        // noop
        undoableItems = _undoableItems;
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSArray* undoItems = [undoableItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        return [obj asDictionary];
    }];
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
            [NSNumber numberWithBool:self.canUndo], @"canUndo",
            undoItems, @"undoItems",
            nil];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSArray* undoItems = [dict objectForKey:@"undoItems"];
    undoItems = [undoItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NSString* className = [obj objectForKey:@"class"];
        Class class = NSClassFromString(className);
        return [[class alloc] initFromDictionary:obj forPage:_page];
    }];
    if(self = [self initForPage:_page withItems:undoItems]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

@end
