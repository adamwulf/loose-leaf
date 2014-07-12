//
//  MMUndoRedoMoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/7/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoMoveScrapItem.h"
#import "MMUndoablePaperView.h"
#import "MMUndoRedoAddScrapItem.h"
#import "MMUndoRedoGroupItem.h"

@interface MMUndoRedoMoveScrapItem (Private)

@property (readonly) NSDictionary* startProperties;
@property (readonly) NSDictionary* endProperties;
@property (readonly) MMScrapView* scrap;

@end

@implementation MMUndoRedoMoveScrapItem{
    NSDictionary* startProperties;
    NSDictionary* endProperties;
    MMScrapView* scrap;
}

-(NSDictionary*) startProperties{
    return startProperties;
}

-(NSDictionary*) endProperties{
    return endProperties;
}

-(MMScrapView*) scrap{
    return scrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap from:(NSDictionary *)startProperties to:(NSDictionary *)endProperties withUndoManager:(MMPageUndoRedoManager*)undoManager{
    return [[MMUndoRedoMoveScrapItem alloc] initForPage:_page andScrap:scrap from:startProperties to:endProperties withUndoManager:undoManager];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap from:(NSDictionary *)_startProperties to:(NSDictionary *)_endProperties withUndoManager:(MMPageUndoRedoManager*)undoManager{
    if(!_startProperties || !_endProperties){
        @throw [NSException exceptionWithName:@"InvalidUndoItem" reason:@"Undo Item must have scrap properties" userInfo:nil];
    }
    __weak MMUndoRedoMoveScrapItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        [weakSelf.scrap setPropertiesDictionary:weakSelf.startProperties];
        NSUInteger subviewIndex = [[weakSelf.startProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [weakSelf.scrap.superview insertSubview:weakSelf.scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        [weakSelf.scrap setPropertiesDictionary:weakSelf.endProperties];
        NSUInteger subviewIndex = [[weakSelf.endProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [weakSelf.scrap.superview insertSubview:weakSelf.scrap atIndex:subviewIndex];
    } forPage:_page withUndoManager:undoManager]){
        // noop
        scrap = _scrap;
        startProperties = _startProperties;
        endProperties = _endProperties;
    };
    return self;
}

-(BOOL) shouldMergeWith:(NSObject<MMUndoRedoItem> *)otherItem{
    if([otherItem isKindOfClass:[MMUndoRedoAddScrapItem class]] &&
       ((MMUndoRedoAddScrapItem*)otherItem).scrap == scrap){
        return YES;
    }
    return NO;
}

-(NSObject<MMUndoRedoItem>*) mergedItemWith:(NSObject<MMUndoRedoItem>*)otherItem{
    return [MMUndoRedoGroupItem itemForPage:self.page withItems:@[self, otherItem] withUndoManager:self.undoRedoManager];
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:startProperties forKey:@"startProperties"];
    [propertiesDictionary setObject:endProperties forKey:@"endProperties"];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page withUndoRedoManager:(MMPageUndoRedoManager*)undoRedoManager{
    NSDictionary* _startProperties = [dict objectForKey:@"startProperties"];
    NSDictionary* _endProperties = [dict objectForKey:@"endProperties"];
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [undoRedoManager.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap from:_startProperties to:_endProperties withUndoManager:undoRedoManager]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMUndoRedoMoveScrapItem %@]", scrap.uuid];
}

@end
