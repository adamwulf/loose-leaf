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
    NSDictionary* properties;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap{
    return [[MMUndoRedoAddScrapFromBezelItem alloc] initForPage:_page andScrap:scrap];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap{
    __weak MMUndoablePaperView* weakPage = _page;
    scrap = _scrap;
    properties = [scrap propertiesDictionary];
    if(self = [super initWithUndoBlock:^{
        [weakPage.bezelContainerView addScrapToBezelSidebar:scrap animated:YES];
    } andRedoBlock:^{
        [weakPage.bezelContainerView didTapOnScrapFromMenu:scrap withPreferredScrapProperties:properties];
    } forPage:_page]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    [propertiesDictionary setObject:properties forKey:@"properties"];
    
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [_page.scrapsOnPaperState scrapForUUID:scrapUUID];
    NSDictionary* propertiesInDict = [dict objectForKey:@"properties"];
    if(self = [self initForPage:_page andScrap:_scrap]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
        properties = propertiesInDict;
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrap.uuid];
}

@end
