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
#import "MMVector.h"
#import <MessageUI/MFMailComposeViewController.h>

/**
 * the purpose of this subclass is to encompass all of the
 * scrap functionality for a page
 */
@interface MMScrappedPaperView : MMEditablePaperView<MFMailComposeViewControllerDelegate,MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapsOnPaperStateDelegate,MMDecompressImagePromiseDelegate>{
    UIImageView* cachedImgView;
}

@property (readonly) MMScrapsOnPaperState* scrapsOnPaperState;
@property (readonly) MMScrapContainerView* scrapContainerView;
@property (readonly) UIImageView* cachedImgView;

-(dispatch_queue_t) serialBackgroundQueue;

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andScale:(CGFloat)scale;
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale;

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading;

-(void) saveToDisk;

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

-(void) updateThumbnailVisibility;

-(NSString*) scrapIDsPath;

@end
