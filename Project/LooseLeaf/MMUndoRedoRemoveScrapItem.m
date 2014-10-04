//
//  MMUndoRedoRemoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoRemoveScrapItem.h"
#import "MMUndoablePaperView.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMScrapsOnPaperState.h"
#import "MMTrashManager.h"

@interface MMUndoRedoRemoveScrapItem (Private)

@property (readonly) NSDictionary* propertiesWhenRemoved;

@end

@implementation MMUndoRedoRemoveScrapItem{
    NSDictionary* propertiesWhenRemoved;
    NSString* scrapUUID;
}

@synthesize scrapUUID;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties{
    return [[MMUndoRedoRemoveScrapItem alloc] initForPage:_page andScrapUUID:scrapUUID andProperties:scrapProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID andProperties:(NSDictionary*)scrapProperties{
    __weak MMUndoRedoRemoveScrapItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        if(!scrap){
            NSLog(@"failed to load scrap!");
        }else{
            [weakSelf.page.scrapsOnPaperState showScrap:scrap];
            [scrap setPropertiesDictionary:weakSelf.propertiesWhenRemoved];
            NSUInteger subviewIndex = [[weakSelf.propertiesWhenRemoved objectForKey:@"subviewIndex"] unsignedIntegerValue];
            [scrap.superview insertSubview:scrap atIndex:subviewIndex];
        }
    } andRedoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [weakSelf.page.scrapsOnPaperState hideScrap:scrap];
    } forPage:_page]){
        scrapUUID = _scrapUUID;
        propertiesWhenRemoved = scrapProperties;
    };
    return self;
}

#pragma mark - Finalize

-(void) finalizeUndoableState{
    // if the remove scrap item is left in the undoable state
    // then that means the user has removed the scrap and kept it
    // removed. if we're here, there's a chance (i think) that the
    // scrap could be in the bezel.
    //
    // if so, then we shouldn't delete it from disk. otherwise
    // we should delete it from disk.
    [[MMTrashManager sharedInstance] deleteScrap:scrapUUID inPage:page];
}

-(void) finalizeRedoableState{
    // if this undo item is redoable, it means they've undone removing the scrap
    // so the scrap still exists on the page as far as we know
    // we shouldn't do anything
}

#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenRemoved forKey:@"propertiesWhenRemoved"];
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenRemoved"];
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

-(NSDictionary*) propertiesWhenRemoved{
    return propertiesWhenRemoved;
}

#pragma mark - Scrap Checking

-(BOOL) containsScrapUUID:(NSString*)_scrapUUID{
    return [scrapUUID isEqualToString:_scrapUUID];
}

@end
