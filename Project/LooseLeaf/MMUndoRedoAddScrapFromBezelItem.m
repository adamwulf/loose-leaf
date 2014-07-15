//
//  MMUndoRedoAddScrapFromBezelItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoAddScrapFromBezelItem.h"
#import "MMUndoablePaperView.h"
#import "MMScrapSidebarContainerView.h"

@implementation MMUndoRedoAddScrapFromBezelItem{
    MMScrapView* scrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoAddScrapFromBezelItem alloc] initForPage:_page andScrap:scrap withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap withUndoManager:(MMPageUndoRedoManager*)undoManager{
    __weak MMUndoablePaperView* weakPage = _page;
    scrap = _scrap;
    if(self = [super initWithUndoBlock:^{
        [weakPage.bezelContainerView addScrapToBezelSidebar:scrap animated:YES];
    } andRedoBlock:^{
        [weakPage.bezelContainerView didTapOnScrapFromMenu:scrap withPreferredScrapProperties:nil];
    } forPage:_page withUndoManager:undoManager]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoRedoManager{
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [undoRedoManager.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap withUndoManager:undoRedoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrap.uuid];
}

@end
