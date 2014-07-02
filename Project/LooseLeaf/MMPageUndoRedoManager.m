//
//  MMPageUndoRedoManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPageUndoRedoManager.h"
#import "MMUndoRedoItem.h"
#import <JotUI/JotUI.h>

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
        [item undo];
        [stackOfUndoableItems addObject:item];
    }
}

@end
