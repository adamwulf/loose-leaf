//
//  MMClonePaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMClonePaperStackView.h"
#import "NSURL+UTI.h"
#import "MMPageCloner.h"
#import "Mixpanel.h"
#import "MMShadowHand.h"


@interface MMListPaperStackView (Protected)

- (void)realignPagesInListView:(NSSet*)pagesToMove animated:(BOOL)animated forceRecalculateAll:(BOOL)recalculateAll;

@end


@implementation MMClonePaperStackView {
    MMPageCloner* pageCloner;

    UITouch* touchForScrollShadow;
}

#pragma mark - MMStretchPageGestureRecognizerDelegate

- (void)didPickUpAPageInListView:(MMLongPressFromListViewGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // noop
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateFailed ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [pageCloner abortClone];
        pageCloner = nil;
    }

    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        if (gesture.pinchedPage.center.x > CGRectGetWidth([self bounds]) - kBezelInGestureWidth) {
            // properties for drag behavior
            realizedThatPageIsBeingDragged = NO;
            pageBeingDragged = nil;
            // go to page/list view
            // based on how the gesture ended
            [self setScrollEnabled:YES];
            [self.stackDelegate.bezelPagesContainer addViewToCountableSidebar:(MMEditablePaperView*)gesture.pinchedPage animated:YES];
            [self realignPagesInListView:[NSSet setWithArray:[self findPagesInVisibleRowsOfListView]] animated:YES forceRecalculateAll:YES];
            [self finishUITransitionToListView];
            [silhouette endPanningObject:gesture.view];
            [silhouette endDrawingAtTouch:[gesture.validTouches firstObject]];
            return;
        }
    }

    [super didPickUpAPageInListView:gesture];


    // silhouette
    if ([gesture isKindOfClass:[MMPanAndPinchFromListViewGestureRecognizer class]]) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [silhouette startPanningObject:gesture.view withTouches:gesture.validTouches];
        } else if (gesture.state == UIGestureRecognizerStateChanged) {
            [silhouette continuePanningObject:gesture.view withTouches:gesture.validTouches];
        } else if (gesture.state == UIGestureRecognizerStateEnded ||
                   gesture.state == UIGestureRecognizerStateCancelled) {
            [silhouette endPanningObject:gesture.view];
        }


        if ([gesture isKindOfClass:[MMStretchPageGestureRecognizer class]]) {
            MMStretchPageGestureRecognizer* stretchGesture = (MMStretchPageGestureRecognizer*)gesture;

            if ([[stretchGesture additionalTouches] count] == 2) {
                if (gesture.state == UIGestureRecognizerStateChanged) {
                    [silhouette continuePanningObject:pageCloner withTouches:stretchGesture.additionalTouches];
                } else if (gesture.state == UIGestureRecognizerStateEnded ||
                           gesture.state == UIGestureRecognizerStateCancelled) {
                    [silhouette endPanningObject:pageCloner];
                }
            }
        }
    } else {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [silhouette startDrawingAtTouch:[gesture.validTouches firstObject] immediately:NO];
        } else if (gesture.state == UIGestureRecognizerStateChanged) {
            [silhouette continueDrawingAtTouch:[gesture.validTouches firstObject]];
        } else if (gesture.state == UIGestureRecognizerStateEnded ||
                   gesture.state == UIGestureRecognizerStateCancelled) {
            [silhouette endDrawingAtTouch:[gesture.validTouches firstObject]];
        }
    }

    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        [silhouette endPanningObject:pageCloner];
    }
}

- (void)didCancelStretchToDuplicatePageWithGesture:(MMStretchPageGestureRecognizer*)gesture {
    [silhouette endPanningObject:pageCloner];
    [pageCloner abortClone];
    pageCloner = nil;
}

- (void)didBeginStretchToDuplicatePageWithGesture:(MMStretchPageGestureRecognizer*)gesture {
    pageCloner = [[MMPageCloner alloc] initWithOriginalUUID:[gesture.pinchedPage uuid] clonedUUID:[[NSUUID UUID] UUIDString] inStackUUID:[self uuid]];
    [pageCloner beginClone];
    [silhouette startPanningObject:pageCloner withTouches:gesture.additionalTouches];
    [self.window.layer setSpeed:0.5f];
}

- (void)didStretchToDuplicatePageWithGesture:(MMStretchPageGestureRecognizer*)gesture withOffset:(CGPoint)offset {
    CGRect targetFrame = gesture.pinchedPage.bounds;
    targetFrame.origin = gesture.pinchedPage.frame.origin;
    targetFrame.origin.x += offset.x - CGRectGetWidth(targetFrame) / 2;
    targetFrame.origin.y += offset.y;
    BOOL shouldSubOne = targetFrame.origin.x < 0;
    targetFrame.origin.x = MIN(MAX(0, targetFrame.origin.x), CGRectGetWidth([self bounds]));

    CGPoint targetPoint = CGRectGetMidPoint(targetFrame);

    NSInteger row = (targetPoint.y) / ([MMListPaperStackView rowHeight] + [MMListPaperStackView bufferWidth]);
    NSInteger col = targetPoint.x / (([MMListPaperStackView columnWidth] + [MMListPaperStackView bufferWidth]) + [MMListPaperStackView bufferWidth] / kNumberOfColumnsInListView);
    NSInteger index = row * kNumberOfColumnsInListView + col - shouldSubOne;
    if (col == kNumberOfColumnsInListView - 1) {
        index -= 1;
    }
    CGRect targetPageFrame = [self frameForIndexInList:index];

    [pageCloner finishCloneAndThen:^(NSString* clonedUUID) {
        CheckMainThread;

        MMExportablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:self.bounds andUUID:clonedUUID];
        page.delegate = self;
        // this like will ensure the new page slides in with
        // its preview properly loaded in time.
        [page loadCachedPreviewAndDecompressImmediately:YES];

        page.frame = targetFrame;

        MMPaperView* pageToInsertAfter = [self pageForPointInList:CGRectGetMidPoint(targetPageFrame)];

        if (!pageToInsertAfter) {
            pageToInsertAfter = gesture.pinchedPage;
        }

        if ([visibleStackHolder containsSubview:pageToInsertAfter]) {
            [visibleStackHolder insertPage:page abovePage:pageToInsertAfter];
        } else if ([hiddenStackHolder containsSubview:pageToInsertAfter]) {
            [hiddenStackHolder insertPage:page abovePage:pageToInsertAfter];
        }

        [[Mixpanel sharedInstance] track:kMPEventClonePage];
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
        [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedPage: @(YES) }];

        NSMutableArray* pagesToMove = [[self findPagesInVisibleRowsOfListView] mutableCopy];
        [pagesToMove removeObject:gesture.pinchedPage];

        [self realignPagesInListView:[NSSet setWithArray:pagesToMove] animated:YES forceRecalculateAll:YES];

        [self saveStacksToDisk];

        [silhouette endPanningObject:pageCloner];
        pageCloner = nil;
    }];
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    touchForScrollShadow = [touches anyObject];
    [super touchesBegan:touches withEvent:event];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    if (touchForScrollShadow) {
        if (!silhouette.rightHand.isDrawing) {
            [silhouette startDrawingAtTouch:touchForScrollShadow immediately:YES];
        }
        [silhouette continueDrawingAtTouch:touchForScrollShadow];
    }

    [super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    [silhouette endDrawingAtTouch:touchForScrollShadow];
    touchForScrollShadow = nil;
}


@end
