//
//  MMUndoRedoAddScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoAddScrapItem.h"
#import "MMUndoablePaperView.h"
#import "MMPageUndoRedoManager.h"

@implementation MMUndoRedoAddScrapItem{
    NSDictionary* propertiesWhenAdded;
    MMScrapView* scrap;
}

@synthesize scrap;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoAddScrapItem alloc] initForPage:_page andScrap:scrap withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [self initForPage:_page andScrap:_scrap andProperties:[_scrap propertiesDictionary] withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap andProperties:(NSDictionary*)properties withUndoManager:(MMPageUndoRedoManager*)undoManager{
    __weak MMUndoablePaperView* weakPage = _page;
    propertiesWhenAdded = properties;
    scrap = _scrap;
    if(!propertiesWhenAdded){
        propertiesWhenAdded = [_scrap propertiesDictionary];
        @throw [NSException exceptionWithName:@"InvalidUndoItem" reason:@"Undo Item must have scrap properties" userInfo:nil];
    }
    if(self = [super initWithUndoBlock:^{
        [weakPage.scrapsOnPaperState hideScrap:scrap];
    } andRedoBlock:^{
        NSUInteger subviewIndex = [[propertiesWhenAdded objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [weakPage.scrapsOnPaperState showScrap:scrap atIndex:subviewIndex];
        [scrap setPropertiesDictionary:propertiesWhenAdded];
    } forPage:_page withUndoManager:undoManager]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenAdded forKey:@"propertiesWhenAdded"];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoRedoManager{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenAdded"];
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [undoRedoManager.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap andProperties:_properties withUndoManager:undoRedoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMUndoRedoAddScrapItem %@]", scrap.uuid];
}

@end
