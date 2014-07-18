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

@end

@implementation MMUndoRedoMoveScrapItem{
    NSDictionary* startProperties;
    NSDictionary* endProperties;
    NSString* scrapUUID;
}

@synthesize scrapUUID;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID from:(NSDictionary *)startProperties to:(NSDictionary *)endProperties{
    return [[MMUndoRedoMoveScrapItem alloc] initForPage:_page andScrapUUID:scrapUUID from:startProperties to:endProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID from:(NSDictionary *)_startProperties to:(NSDictionary *)_endProperties{
    if(!_startProperties || !_endProperties){
        @throw [NSException exceptionWithName:@"InvalidUndoItem" reason:@"Undo Item must have scrap properties" userInfo:nil];
    }
    __weak MMUndoRedoMoveScrapItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [scrap setPropertiesDictionary:weakSelf.startProperties];
        NSUInteger subviewIndex = [[weakSelf.startProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [scrap setPropertiesDictionary:weakSelf.endProperties];
        NSUInteger subviewIndex = [[weakSelf.endProperties objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } forPage:_page]){
        // noop
        scrapUUID = _scrapUUID;
        startProperties = _startProperties;
        endProperties = _endProperties;
    };
    return self;
}

-(BOOL) shouldMergeWith:(NSObject<MMUndoRedoItem> *)otherItem{
    if([otherItem isKindOfClass:[MMUndoRedoAddScrapItem class]] &&
       [((MMUndoRedoAddScrapItem*)otherItem).scrapUUID isEqualToString:scrapUUID]){
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
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _startProperties = [dict objectForKey:@"startProperties"];
    NSDictionary* _endProperties = [dict objectForKey:@"endProperties"];
    NSString* _scrapUUID = [dict objectForKey:@"scrapUUID"];
    
    if(self = [self initForPage:_page andScrapUUID:_scrapUUID from:_startProperties to:_endProperties]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrapUUID];
}

#pragma mark - Private Properties


-(NSDictionary*) startProperties{
    return startProperties;
}

-(NSDictionary*) endProperties{
    return endProperties;
}

@end
