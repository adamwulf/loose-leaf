//
//  MMUndoablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "MMPageUndoRedoManager.h"

@interface MMUndoablePaperView : MMScrappedPaperView

@property (nonatomic, readonly) MMPageUndoRedoManager* undoRedoManager;
@property (readonly) NSString* undoStatePath;

-(void) addUndoItemForScrap:(MMScrapView*)scrap thatMovedFrom:(NSDictionary*)startProperties to:(NSDictionary*)endProperties;

-(void) addUndoItemForRemovedScrap:(MMScrapView*)scrap withProperties:(NSDictionary*)scrapProperties;

-(void) addUndoItemForAddedScrap:(MMScrapView*)scrap;

@end
