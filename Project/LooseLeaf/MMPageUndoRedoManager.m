//
//  MMPageUndoRedoManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPageUndoRedoManager.h"
#import <JotUI/JotUI.h>
#import "Constants.h"

@implementation MMPageUndoRedoManager{
    NSMutableArray* stackOfUndoableItems;
    NSMutableArray* stackOfUndoneItems;
}


-(id) init{
    if(self = [super init]){
        stackOfUndoableItems = [NSMutableArray array];
        stackOfUndoneItems = [NSMutableArray array];
    }
    return self;
}

-(void) addUndoItem:(NSObject<MMUndoRedoItem>*)item{
    
    [stackOfUndoneItems makeObjectsPerformSelector:@selector(finalizeRedoneState)];
    [stackOfUndoneItems removeAllObjects];
    [stackOfUndoableItems addObject:item];
    while([stackOfUndoableItems count] > kUndoLimit){
        NSObject<MMUndoRedoItem>* item = [stackOfUndoableItems firstObject];
        [stackOfUndoableItems removeObject:item];
        [item finalizeUndoneState];
    }
    
}

-(void) undo{
    CheckMainThread;
    
    NSObject<MMUndoRedoItem>* item = [stackOfUndoableItems lastObject];
    if(item){
        [stackOfUndoableItems removeLastObject];
        [item undo];
        [stackOfUndoneItems addObject:item];
    }
}

-(void) redo{
    CheckMainThread;
    
    NSObject<MMUndoRedoItem>* item = [stackOfUndoneItems lastObject];
    if(item){
        [stackOfUndoneItems removeLastObject];
        [item redo];
        [stackOfUndoableItems addObject:item];
    }
}

@end
