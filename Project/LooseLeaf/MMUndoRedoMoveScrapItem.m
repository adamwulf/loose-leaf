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

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap from:(NSDictionary *)startProperties to:(NSDictionary *)endProperties{
    return [[MMUndoRedoMoveScrapItem alloc] initForPage:_page andScrap:scrap from:startProperties to:endProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap from:(NSDictionary *)_startProperties to:(NSDictionary *)_endProperties{
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
    } forPage:_page]){
        // noop
        scrap = _scrap;
        startProperties = _startProperties;
        endProperties = _endProperties;
    };
    return self;
}

-(BOOL) shouldMergeWith:(NSObject<MMUndoRedoItem> *)otherItem{
    if([otherItem isKindOfClass:[MMUndoRedoAddScrapItem class]] &&
       [((MMUndoRedoAddScrapItem*)otherItem).scrapUUID isEqualToString:scrap.uuid]){
        return YES;
    }
    return NO;
}

-(NSObject<MMUndoRedoItem>*) mergedItemWith:(NSObject<MMUndoRedoItem>*)otherItem{
    return [MMUndoRedoGroupItem itemForPage:self.page withItems:@[self, otherItem]];
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

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _startProperties = [dict objectForKey:@"startProperties"];
    NSDictionary* _endProperties = [dict objectForKey:@"endProperties"];
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [_page.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap from:_startProperties to:_endProperties]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrap.uuid];
}

@end
