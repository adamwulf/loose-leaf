//
//  MMUndoRedoRemoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoBezeledScrapItem.h"
#import "MMUndoablePaperView.h"
#import "MMScrapSidebarContainerView.h"

@implementation MMUndoRedoBezeledScrapItem{
    NSDictionary* propertiesWhenRemoved;
    MMScrapView* scrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap andProperties:(NSDictionary*)scrapProperties withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoBezeledScrapItem alloc] initForPage:_page andScrap:scrap andProperties:scrapProperties withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap andProperties:(NSDictionary*)scrapProperties withUndoManager:(MMPageUndoRedoManager*)undoManager{
    __weak MMUndoablePaperView* weakPage = _page;
    scrap = _scrap;
    propertiesWhenRemoved = scrapProperties;
    if(self = [super initWithUndoBlock:^{
        [weakPage.scrapsOnPaperState showScrap:scrap];
        [scrap setPropertiesDictionary:propertiesWhenRemoved];
        NSUInteger subviewIndex = [[propertiesWhenRemoved objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        [weakPage.scrapsOnPaperState hideScrap:scrap];
    } forPage:_page withUndoManager:undoManager]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenRemoved forKey:@"propertiesWhenRemoved"];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoRedoManager{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenRemoved"];
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [undoRedoManager.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap andProperties:_properties withUndoManager:undoRedoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMUndoRedoRemoveScrapItem %@]", scrap.uuid];
}

@end
