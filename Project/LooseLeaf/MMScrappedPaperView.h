//
//  MMScrappedPaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperView.h"
#import "MMPanAndPinchScrapGestureRecognizer.h"
#import "MMPanAndPinchScrapGestureRecognizerDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

/**
 * the purpose of this subclass is to encompass all of the
 * scrap functionality for a page
 */
@interface MMScrappedPaperView : MMEditablePaperView<MFMailComposeViewControllerDelegate,MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapsOnPaperStateDelegate>

@property (readonly) NSArray* scraps;

-(void) addScrap:(MMScrapView*)scrap;
-(BOOL) hasScrap:(MMScrapView*)scrap;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

-(void) saveToDisk;

#pragma mark - Scissors

-(void) beginScissorAtPoint:(CGPoint)point;

-(BOOL) continueScissorAtPoint:(CGPoint)point;

-(void) finishScissorAtPoint:(CGPoint)point;

-(void) cancelScissorAtPoint:(CGPoint)point;

@end
