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
    NSString* scrapUUID;
    BOOL sidebarEverDidContainScrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties{
    return [[MMUndoRedoBezeledScrapItem alloc] initForPage:_page andScrapUUID:scrapUUID andProperties:scrapProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID andProperties:(NSDictionary*)scrapProperties{
    sidebarEverDidContainScrap = NO;
    scrapUUID = _scrapUUID;
    propertiesWhenRemoved = scrapProperties;
    __weak MMUndoRedoBezeledScrapItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:scrapUUID];
        if([weakSelf.page.bezelContainerView containsScrap:scrap]){
            sidebarEverDidContainScrap = YES;
            [weakSelf.page.bezelContainerView didTapOnScrapFromMenu:scrap withPreferredScrapProperties:scrapProperties];
        }else{
            sidebarEverDidContainScrap = NO;
            [weakSelf.page.scrapsOnPaperState showScrap:scrap];
            [scrap setPropertiesDictionary:propertiesWhenRemoved];
            NSUInteger subviewIndex = [[propertiesWhenRemoved objectForKey:@"subviewIndex"] unsignedIntegerValue];
            [scrap.superview insertSubview:scrap atIndex:subviewIndex];
        }
    } andRedoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:scrapUUID];
        if(sidebarEverDidContainScrap){
            [weakSelf.page.bezelContainerView addScrapToBezelSidebar:scrap animated:YES];
        }else{
            [weakSelf.page.scrapsOnPaperState hideScrap:scrap];
        }
    } forPage:_page]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenRemoved forKey:@"propertiesWhenRemoved"];
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    [propertiesDictionary setObject:[NSNumber numberWithBool:sidebarEverDidContainScrap] forKey:@"sidebarEverDidContainScrap"];
    
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenRemoved"];
    NSString* _scrapUUID = [dict objectForKey:@"scrapUUID"];
    
    if(self = [self initForPage:_page andScrapUUID:_scrapUUID andProperties:_properties]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
        sidebarEverDidContainScrap = [[dict objectForKey:@"sidebarEverDidContainScrap"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrapUUID];
}

@end
