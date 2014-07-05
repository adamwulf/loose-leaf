//
//  MMPageUndoRedoManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPageUndoRedoManager.h"
#import "NSArray+Map.h"
#import <JotUI/JotUI.h>
#import "Constants.h"
#import "MMUndoablePaperView.h"

@implementation MMPageUndoRedoManager{
    MMUndoablePaperView* page;
    NSMutableArray* stackOfUndoableItems;
    NSMutableArray* stackOfUndoneItems;
}


-(id) initForPage:(MMUndoablePaperView*)page{
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

-(void) saveTo:(NSString*)path{
    NSArray* saveableStackOfUndoneItems = [stackOfUndoneItems mapObjectsUsingSelector:@selector(asDictionary)];
    NSArray* saveableStackOfUndoableItems = [stackOfUndoableItems mapObjectsUsingSelector:@selector(asDictionary)];
    NSDictionary* objectsToSave = [NSDictionary dictionaryWithObjectsAndKeys:saveableStackOfUndoneItems, @"saveableStackOfUndoneItems", saveableStackOfUndoableItems, @"saveableStackOfUndoableItems", nil];
    [objectsToSave writeToFile:path atomically:YES];
}

-(void) loadFrom:(NSString*)path{
    NSDictionary* loadedInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    if(loadedInfo){
        [stackOfUndoneItems removeAllObjects];
        [stackOfUndoableItems removeAllObjects];
        NSArray* loadedUndoneItems = [loadedInfo objectForKey:@"saveableStackOfUndoneItems"];
        NSArray* loadedUndoableItems = [loadedInfo objectForKey:@"saveableStackOfUndoableItems"];

        if(loadedUndoneItems){
            [stackOfUndoneItems addObjectsFromArray:[loadedUndoneItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                NSString* className = [obj objectForKey:@"class"];
                Class class = NSClassFromString(className);
                return [[class alloc] initFromDictionary:obj forPage:page];
            }]];
        }

        if(loadedUndoableItems){
            [stackOfUndoableItems addObjectsFromArray:[loadedUndoableItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                NSString* className = [obj objectForKey:@"class"];
                Class class = NSClassFromString(className);
                return [[class alloc] initFromDictionary:obj forPage:page];
            }]];
        }
}
}

@end
