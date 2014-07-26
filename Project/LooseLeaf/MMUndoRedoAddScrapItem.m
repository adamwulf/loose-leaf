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
#import "MMScrapSidebarContainerView.h"
#import "MMTrashManager.h"

@interface MMUndoRedoAddScrapItem (Private)

@property (readonly) NSDictionary* propertiesWhenAdded;

@end

@implementation MMUndoRedoAddScrapItem{
    NSDictionary* propertiesWhenAdded;
    NSString* scrapUUID;
}

@synthesize scrapUUID;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString *)scrapUUID andProperties:(NSDictionary*)properties{
    return [[MMUndoRedoAddScrapItem alloc] initForPage:_page andScrapUUID:scrapUUID andProperties:properties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID andProperties:(NSDictionary*)properties{
    __weak MMUndoRedoAddScrapItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [weakSelf.page.scrapsOnPaperState hideScrap:scrap];
    } andRedoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        NSUInteger subviewIndex = [[weakSelf.propertiesWhenAdded objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [weakSelf.page.scrapsOnPaperState showScrap:scrap atIndex:subviewIndex];
        [scrap setPropertiesDictionary:weakSelf.propertiesWhenAdded];
    } forPage:_page]){
        propertiesWhenAdded = properties;
        scrapUUID = _scrapUUID;
        if(!propertiesWhenAdded || !scrapUUID){
            @throw [NSException exceptionWithName:@"InvalidUndoItem" reason:@"Undo Item must have scrap properties" userInfo:nil];
        }
    };
    return self;
}

#pragma mark - Finalize

-(void) finalizeUndoableState{
    // if this item is undoable, it means the user has
    // added a scrap to the page and has NOT undone the
    // scrap, so as far as we know it's still on the page.
    // this is a noop for us
}

-(void) finalizeRedoableState{
    // if this item is able to be re-done, it means that the user
    // has undone adding the scrap. if this is the case, then
    // the scrap could only ever have been on the page and undone,
    // we don't need to check the bezel.
    // just delete the assets straight away
    [[MMTrashManager sharedInstace] deleteScrap:scrapUUID inPage:page.uuid];
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenAdded forKey:@"propertiesWhenAdded"];
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenAdded"];
    NSString* _scrapUUID = [dict objectForKey:@"scrapUUID"];
    
    if(self = [self initForPage:_page andScrapUUID:_scrapUUID andProperties:_properties]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrapUUID];
}

#pragma mark - Private Properties

-(NSDictionary*) propertiesWhenAdded{
    return propertiesWhenAdded;
}

@end
