//
//  MMScrappedPaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperView.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMDecompressImagePromiseDelegate.h"
#import "MMScissorResult.h"
#import "MMScrapContainerView.h"
#import "MMScrapsOnPaperState.h"
#import "MMScrapViewOwnershipDelegate.h"
#import "MMVector.h"
#import <MessageUI/MFMailComposeViewController.h>

/**
 * the purpose of this subclass is to encompass all of the
 * scrap functionality for a page
 */
@interface MMScrappedPaperView : MMEditablePaperView<MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapsOnPaperStateDelegate,MMDecompressImagePromiseDelegate>{
    MMScrapsOnPaperState* scrapsOnPaperState;
    UIImageView* cachedImgView;
    
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAScrappedThumbnail;
    BOOL isLoadingCachedScrappedThumbnailFromDisk;
}

@property (readonly) MMScrapsOnPaperState* scrapsOnPaperState;
@property (readonly) UIImageView* cachedImgView;
@property (nonatomic, weak) NSObject<MMScrapViewOwnershipDelegate,MMPaperViewDelegate>* delegate;

-(dispatch_queue_t) serialBackgroundQueue;

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andScale:(CGFloat)scale;
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale;

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading;

#pragma mark - Scissors

-(void) beginScissorAtPoint:(CGPoint)point;

-(BOOL) continueScissorAtPoint:(CGPoint)point;

-(void) finishScissorAtPoint:(CGPoint)point;

-(void) cancelScissorAtPoint:(CGPoint)point;

-(MMScissorResult*) completeScissorsCutWithPath:(UIBezierPath*)scissorPath;

-(NSString*) scrappedThumbnailPath;

-(UIImage*) scrappedImgViewImage;

-(void) addUndoLevelAndContinueStroke;

-(void) performBlockForUnloadedScrapStateSynchronously:(void(^)())block andImmediatelyUnloadState:(BOOL)shouldImmediatelyUnload andSavePaperState:(BOOL)shouldSavePaperState;

-(NSString*) scrapIDsPath;

-(NSArray*) scrapsOnPaper;

-(CGSize) thumbnailSize;

#pragma mark - protected

-(void) loadCachedPreviewAndDecompressImmediately:(BOOL)forceToDecompressImmediately;

-(void) isShowingDrawableView:(BOOL)showDrawableView andIsShowingThumbnail:(BOOL)showThumbnail;

-(void) drawPageBackgroundInContext:(CGContextRef)context forThumbnailSize:(CGSize)thumbSize;

-(void) setThumbnailTo:(UIImage*)img;

-(void) newlyCutScrapFromPaperView:(MMScrapView*)scrap;

@end
