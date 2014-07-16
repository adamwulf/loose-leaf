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
#import "MMUndoRedoPageItem.h"
#import "MMUndoRedoAddScrapItem.h"
#import "MMUndoRedoBezeledScrapItem.h"

@implementation MMPageUndoRedoManager{
    MMUndoablePaperView* page;
    NSMutableArray* stackOfUndoableItems;
    NSMutableArray* stackOfUndoneItems;
    BOOL hasEditsToSave;
    BOOL isLoaded;
    __weak MMScrapsOnPaperState* scrapsOnPaperState;
}

@synthesize scrapsOnPaperState;
@synthesize hasEditsToSave;


-(id) initForPage:(MMUndoablePaperView*)_page{
    if(self = [super init]){
        page = _page;
        stackOfUndoableItems = [NSMutableArray array];
        stackOfUndoneItems = [NSMutableArray array];
        hasEditsToSave = NO;
        isLoaded = NO;
    }
    return self;
}

-(void) addUndoItem:(NSObject<MMUndoRedoItem>*)item{
    @synchronized(self){
        BOOL needsLoad = !isLoaded;
        if(needsLoad){
            [self loadFrom:page.undoStatePath];
        }
        [stackOfUndoneItems makeObjectsPerformSelector:@selector(finalizeRedoneState)];
        [stackOfUndoneItems removeAllObjects];
        [stackOfUndoableItems addObject:item];
        while([stackOfUndoableItems count] > kUndoLimit){
            NSObject<MMUndoRedoItem>* item = [stackOfUndoableItems firstObject];
            [stackOfUndoableItems removeObject:item];
            [item finalizeUndoneState];
        }
        hasEditsToSave = YES;
        [self printDescription];
        if(needsLoad){
            [self saveTo:page.undoStatePath];
            [self unloadState];
            NSLog(@"done saving unloaded undo manager");
        }
    }
}

-(void) mergeItemsIfPossible{
    @throw [NSException exceptionWithName:@"UnusedMethod" reason:@"This method should not be used until functionality is defined" userInfo:nil];
    MMUndoRedoPageItem* lastItem = [stackOfUndoableItems lastObject];
    MMUndoRedoPageItem* almostLastItem = [stackOfUndoableItems lastObject];
    if([lastItem shouldMergeWith:almostLastItem]){
        // remove last 2 objects and merge
        [stackOfUndoableItems removeLastObject];
        [stackOfUndoableItems removeLastObject];
        [stackOfUndoableItems addObject:[lastItem mergedItemWith:almostLastItem]];
    }
}

-(void) undo{
    CheckMainThread;
    
    @synchronized(self){
        NSObject<MMUndoRedoItem>* item = [stackOfUndoableItems lastObject];
        if(item){
            [stackOfUndoableItems removeLastObject];
            [item undo];
            [stackOfUndoneItems addObject:item];
        }
        hasEditsToSave = YES;
        [self printDescription];
    }
}

-(void) redo{
    CheckMainThread;
    @synchronized(self){
        NSObject<MMUndoRedoItem>* item = [stackOfUndoneItems lastObject];
        if(item){
            [stackOfUndoneItems removeLastObject];
            [item redo];
            [stackOfUndoableItems addObject:item];
        }
        hasEditsToSave = YES;
        [self printDescription];
    }
}

-(void) printDescription{
    return;
    NSLog(@"***************************");
    NSLog(@"stackOfUndoneItems:");
    for(NSObject<MMUndoRedoItem>*obj in stackOfUndoneItems){
        NSLog(@"%@", obj);
    }
    NSLog(@"stackOfUndoableItems:");
    for(NSObject<MMUndoRedoItem>*obj in stackOfUndoableItems){
        NSLog(@"%@", obj);
    }
    NSLog(@"***************************");
}

-(void) saveTo:(NSString*)path{
    if(!isLoaded){
        @throw [NSException exceptionWithName:@"SavingUnloadedUndoManager" reason:@"Cannot save unloaded undo manager" userInfo:nil];
    }
    if(!hasEditsToSave){
//        NSLog(@"no edits to save for undo state: %@", path);
        return;
    }
    NSArray* saveableStackOfUndoneItems;
    NSArray* saveableStackOfUndoableItems;
    @synchronized(self){
        saveableStackOfUndoneItems = [stackOfUndoneItems mapObjectsUsingSelector:@selector(asDictionary)];
        saveableStackOfUndoableItems = [stackOfUndoableItems mapObjectsUsingSelector:@selector(asDictionary)];
        hasEditsToSave = NO;
    }
    NSDictionary* objectsToSave = [NSDictionary dictionaryWithObjectsAndKeys:saveableStackOfUndoneItems, @"saveableStackOfUndoneItems", saveableStackOfUndoableItems, @"saveableStackOfUndoableItems", nil];
    [objectsToSave writeToFile:path atomically:YES];
}

-(void) loadFrom:(NSString*)path{
    isLoaded = YES;
    NSDictionary* loadedInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    if(loadedInfo){
        @synchronized(self){
            [stackOfUndoneItems removeAllObjects];
            [stackOfUndoableItems removeAllObjects];
            NSArray* loadedUndoneItems = [loadedInfo objectForKey:@"saveableStackOfUndoneItems"];
            NSArray* loadedUndoableItems = [loadedInfo objectForKey:@"saveableStackOfUndoableItems"];
            
            if(loadedUndoneItems){
                [stackOfUndoneItems addObjectsFromArray:[loadedUndoneItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                    NSString* className = [obj objectForKey:@"class"];
                    Class class = NSClassFromString(className);
                    return [[class alloc] initFromDictionary:obj forPage:page withUndoRedoManager:self];
                }]];
            }
            
            if(loadedUndoableItems){
                [stackOfUndoableItems addObjectsFromArray:[loadedUndoableItems mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                    NSString* className = [obj objectForKey:@"class"];
                    Class class = NSClassFromString(className);
                    return [[class alloc] initFromDictionary:obj forPage:page withUndoRedoManager:self];
                }]];
            }
            hasEditsToSave = NO;
        }
    }
}

-(void) unloadState{
    @synchronized(self){
        if(hasEditsToSave){
            @throw [NSException exceptionWithName:@"UnloadUndoStateException" reason:@"Unloading Undo State that has edits to save" userInfo:nil];
        }
        isLoaded = NO;
        [stackOfUndoableItems removeAllObjects];
        [stackOfUndoneItems removeAllObjects];
    }
}


// debug method to see if we just undid adding a scrap to the bezel
-(BOOL) justUndidScrapBezel{
    return [[stackOfUndoneItems firstObject] isKindOfClass:[MMUndoRedoBezeledScrapItem class]];
}

@end
