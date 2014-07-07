//
//  MMUndoRedoItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMUndoablePaperView;

@protocol MMUndoRedoItem <NSObject>

-(void) undo;

-(void) redo;

-(void) finalizeUndoneState;

-(void) finalizeRedoneState;

#pragma mark - Save and Load

-(NSDictionary*) asDictionary;

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)page;

-(BOOL) shouldMergeWith:(NSObject<MMUndoRedoItem>*)otherItem;

-(NSObject<MMUndoRedoItem>*) mergedItemWith:(NSObject<MMUndoRedoItem>*)otherItem;

@end
