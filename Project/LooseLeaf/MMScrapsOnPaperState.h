//
//  MMScrapsOnPaperState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMScrapCollectionState.h"

@class MMImmutableScrapsOnPaperState;

@interface MMScrapsOnPaperState : MMScrapCollectionState{
    __weak NSObject<MMScrapsOnPaperStateDelegate>* delegate;
}

@property (nonatomic, readonly) NSObject<MMScrapsOnPaperStateDelegate>* delegate;
@property (nonatomic, readonly) MMScrapContainerView* scrapContainerView;

-(id) initWithDelegate:(NSObject<MMScrapsOnPaperStateDelegate>*)delegate withScrapContainerSize:(CGSize)scrapContainerSize;

-(MMImmutableScrapsOnPaperState*) immutableStateForPath:(NSString*)scrapIDsPath;

#pragma mark - Add Scraps

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale;

#pragma mark - Manage Scraps

-(NSArray*) scrapsOnPaper;

-(void) showScrap:(MMScrapView*)scrap;
-(void) showScrap:(MMScrapView*)scrap atIndex:(NSUInteger)subviewIndex;
-(void) hideScrap:(MMScrapView*)scrap;
-(BOOL) isScrapVisible:(MMScrapView*)scrap;
-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap;

// returns the scrap for the specified uuid, or nil if there's no match
-(MMScrapView*) scrapForUUID:(NSString*)uuid;

-(MMScrapView*) mostRecentScrap;

-(void) removeScrapWithUUID:(NSString*)scrapUUID;

#pragma mark - Paths

-(NSString*) directoryPathForScrapUUID:(NSString*)uuid;

-(NSString*) bundledDirectoryPathForScrapUUID:(NSString*)uuid;


@end
