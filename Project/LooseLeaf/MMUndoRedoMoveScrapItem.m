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

@implementation MMUndoRedoMoveScrapItem{
    NSDictionary* startProperties;
    NSUInteger subviewIndexAtStart;
    NSDictionary* endProperties;
    NSUInteger subviewIndexAtEnd;
    MMScrapView* scrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap from:(NSDictionary *)startProperties to:(NSDictionary *)endProperties{
    return [[MMUndoRedoMoveScrapItem alloc] initForPage:_page andScrap:scrap from:startProperties to:endProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap from:(NSDictionary *)_startProperties to:(NSDictionary *)_endProperties{
    if(!_startProperties || !_endProperties){
        @throw [NSException exceptionWithName:@"InvalidUndoItem" reason:@"Undo Item must have scrap properties" userInfo:nil];
    }
    if(self = [super initWithUndoBlock:^{
        [scrap setPropertiesDictionary:startProperties];
        NSUInteger subviewIndex = [[startProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        [scrap setPropertiesDictionary:endProperties];
        NSUInteger subviewIndex = [[endProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
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
       ((MMUndoRedoAddScrapItem*)otherItem).scrap == scrap){
        return YES;
    }
    return NO;
}

-(NSObject<MMUndoRedoItem>*) mergedItemWith:(NSObject<MMUndoRedoItem>*)otherItem{
    return [MMUndoRedoGroupItem itemForPage:self.page withItems:@[self, otherItem]];
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionary];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    if(self = [self initForPage:_page andScrap:nil from:[dict objectForKey:@"startProperties"] to:[dict objectForKey:@"endProperties"]]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMUndoRedoMoveScrapItem %@]", scrap.uuid];
}

@end
