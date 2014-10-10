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
@interface MMScrappedPaperView : MMEditablePaperView<MFMailComposeViewControllerDelegate,MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapsOnPaperStateDelegate,MMDecompressImagePromiseDelegate>{
    MMScrapsOnPaperState* scrapsOnPaperState;
    UIImageView* cachedImgView;
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

-(void) performBlockForUnloadedScrapStateSynchronously:(void(^)())block;

-(NSString*) scrapIDsPath;

-(NSArray*) scrapsOnPaper;

-(CGSize) thumbnailSize;

#pragma mark - protected

-(void) loadCachedPreviewAndDecompressImmediately:(BOOL)forceToDecompressImmediately;

@end
