//
//  MMPageCacheManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperView.h"
#import "MMUndoablePaperView.h"
#import "MMPageCacheManagerDelegate.h"

// this cache will help ensure that the
// top visible/editable page doesn't
// get thrown out of cache, and that
// apprpriate pages are loaded into
// cache when needed
@interface MMPageCacheManager : NSObject{
    __weak NSObject<MMPageCacheManagerDelegate>* delegate;
    JotView* drawableView;
}

@property (nonatomic, weak) NSObject<MMPageCacheManagerDelegate>* delegate;
@property (nonatomic, strong) JotView* drawableView;
@property (nonatomic, readonly) MMUndoablePaperView* currentEditablePage;

+(MMPageCacheManager*) sharedInstance;

-(void) pageWasDeleted:(MMPaperView*)page;

-(void) mayChangeTopPageTo:(MMPaperView*)page;
-(void) willChangeTopPageTo:(MMPaperView*)page;
-(BOOL) didChangeToTopPage:(MMPaperView*)page;
-(void) willNotChangeTopPageTo:(MMPaperView*)page;

-(void) didLoadStateForPage:(MMEditablePaperView*) page;

-(void) didUnloadStateForPage:(MMEditablePaperView*) page;

-(void) didSavePage:(MMPaperView*)page;

-(void) updateVisiblePageImageCache;

-(NSInteger) numberOfStateLoadedPages;

-(NSInteger) numberOfPagesWithLoadedPreviewImage;

-(int) memoryOfStateLoadedPages;

@end
