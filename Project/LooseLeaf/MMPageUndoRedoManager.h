//
//  MMPageUndoRedoManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMUndoRedoItem.h"
#import "MMScrapsOnPaperState.h"

@interface MMPageUndoRedoManager : NSObject

@property (readonly) BOOL hasEditsToSave;
@property (weak) MMScrapsOnPaperState* scrapsOnPaperState;

-(id) initForPage:(MMUndoablePaperView*)page;

-(void) addUndoItem:(NSObject<MMUndoRedoItem>*)item;

-(void) undo;

-(void) redo;

#pragma mark - Saving and Loading

-(void) saveTo:(NSString*)path;

-(void) loadFrom:(NSString*)path;

-(void) unloadState;

@end
