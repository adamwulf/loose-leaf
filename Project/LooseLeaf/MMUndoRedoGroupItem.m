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

+(id) itemForPage:(MMUndoablePaperView *)_page withItems:(NSArray *)undoableItems withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoGroupItem alloc] initForPage:_page withItems:undoableItems withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView *)_page withItems:(NSArray *)_undoableItems withUndoManager:(MMPageUndoRedoManager*)undoManager{
    if(self = [super initWithUndoBlock:^{
        for(NSObject<MMUndoRedoItem>*obj in undoableItems){
            [obj undo];
        }
    } andRedoBlock:^{
        for(NSObject<MMUndoRedoItem>*obj in [undoableItems reverseObjectEnumerator]){
            [obj redo];
        }
    } forPage:_page withUndoManager:undoManager]){
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

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoManager{
    NSArray* undoItems = [dict objectForKey:@"undoItems"];
    undoItems = [undoItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NSString* className = [obj objectForKey:@"class"];
        Class class = NSClassFromString(className);
        return [[class alloc] initFromDictionary:obj forPage:_page withUndoRedoManager:undoManager];
    }];
    if(self = [self initForPage:_page withItems:undoItems withUndoManager:undoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    NSString* str = @"";
    for(NSObject<MMUndoRedoItem>*obj in undoableItems){
        if(str.length){
            str = [str stringByAppendingString:@",\n"];
        }
        str = [str stringByAppendingString:[obj description]];
    }
    return [NSString stringWithFormat:@"[MMUndoRedoGroupItem (%@)]", str];
}

@end
