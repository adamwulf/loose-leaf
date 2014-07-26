//
//  MMScrapsOnPaperState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsOnPaperStateDelegate.h"

@class MMImmutableScrapsOnPaperState;

@interface MMScrapsOnPaperState : NSObject{
    __weak NSObject<MMScrapsOnPaperStateDelegate>* delegate;
    BOOL shouldShowShadows;
}

@property (nonatomic, readonly) NSObject<MMScrapsOnPaperStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;
@property (nonatomic, assign) BOOL shouldShowShadows;
@property (nonatomic, readonly) int fullByteSize;
@property (readonly) BOOL hasEditsToSave;

+(dispatch_queue_t) importExportStateQueue;

-(id) initWithDelegate:(NSObject<MMScrapsOnPaperStateDelegate>*)delegate;

#pragma mark - Save and Load

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable;

-(void) unload;

-(MMImmutableScrapsOnPaperState*) immutableStateForPath:(NSString*)scrapIDsPath;

#pragma mark - Interaction with Bezel Sidebar

-(void) bezelRelenquishesScrap:(MMScrapView*)scrap;

#pragma mark - Add Scraps

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale;

#pragma mark - Manage Scraps

-(void) showScrap:(MMScrapView*)scrap;
-(void) showScrap:(MMScrapView*)scrap atIndex:(NSUInteger)subviewIndex;
-(void) hideScrap:(MMScrapView*)scrap;
-(BOOL) isScrapVisible:(MMScrapView*)scrap;
-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap;
// returns the scrap for the specified uuid, or nil if there's no match
-(MMScrapView*) scrapForUUID:(NSString*)uuid;

-(MMScrapView*) mostRecentScrap;


@end
