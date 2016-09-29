//
//  MMUndoRedoAddScrapFromBezelItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoAddScrapFromBezelItem.h"
#import "MMUndoablePaperView.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMTrashManager.h"


@interface MMUndoRedoAddScrapFromBezelItem (Private)

@property (readonly) NSDictionary* properties;

@end


@implementation MMUndoRedoAddScrapFromBezelItem {
    NSString* scrapUUID;
    NSDictionary* properties;
}

@synthesize scrapUUID;

+ (id)itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties {
    return [[MMUndoRedoAddScrapFromBezelItem alloc] initForPage:_page andScrapUUID:scrapUUID andProperties:scrapProperties];
}

- (id)initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID andProperties:(NSDictionary*)scrapProperties {
    __weak MMUndoRedoAddScrapFromBezelItem* weakSelf = self;
    if (self = [super initWithUndoBlock:^{
            MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
            [weakSelf.page.bezelContainerView addViewToCountableSidebar:scrap animated:YES];
        } andRedoBlock:^{
            MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
            [weakSelf.page.bezelContainerView didTapOnViewFromMenu:scrap withPreferredScrapProperties:weakSelf.properties below:YES];
        } forPage:_page]) {
        scrapUUID = _scrapUUID;
        properties = scrapProperties;
    };
    return self;
}

#pragma mark - Finalize

- (void)finalizeUndoableState {
    // we've added a scrap to our page from the bezel, and
    // we haven't undone this action. this means the scrap
    // is still on our page, and we should noop
}

- (void)finalizeRedoableState {
    // if this item is undone, then that means we added a scrap
    // to our page, but then sent it back to the bezel.
    // we should check if it's still in the bezel, and if not
    // then we're the last holder of this scrap and should delete it
    [[MMTrashManager sharedInstance] deleteScrap:scrapUUID inScrapCollectionState:page.scrapsOnPaperState];
}

#pragma mark - Serialize

- (NSDictionary*)asDictionary {
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                                                                  [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    [propertiesDictionary setObject:properties forKey:@"properties"];

    return propertiesDictionary;
}

- (id)initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page {
    NSString* _scrapUUID = [dict objectForKey:@"scrapUUID"];
    NSDictionary* propertiesInDict = [dict objectForKey:@"properties"];
    if (self = [self initForPage:_page andScrapUUID:_scrapUUID andProperties:propertiesInDict]) {
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrapUUID];
}

#pragma mark - Private Properties

- (NSDictionary*)properties {
    return properties;
}

#pragma mark - Scrap Checking

- (BOOL)containsScrapUUID:(NSString*)_scrapUUID {
    return [scrapUUID isEqualToString:_scrapUUID];
}

@end
