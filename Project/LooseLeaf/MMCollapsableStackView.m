//
//  MMCollapsableStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCollapsableStackView.h"
#import "MMLargeTutorialSidebarButton.h"
#import "MMFeedbackButton.h"
#import "MMContinuousSwipeGestureRecognizer.h"
#import "MMDeleteButton.h"
#import "MMConfirmDeleteStackButton.h"
#import "MMFullWidthListButtonDelegate.h"
#import "AVHexColor.h"
#import "NSArray+Extras.h"
#import "UIScreen+MMSizing.h"
#import "MMTrashButton.h"
#import "MMColoredTextField.h"
#import "MMEmptyStackButton.h"
#import "MMArrowView.h"
#import "UIColor+MMAdditions.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMPDFAssetGroup.h"
#import "MMImportingPDFListButton.h"
#import "MMBlockOperation.h"
#import "MMDecryptPDFStackButton.h"
#import "MMCollapseButton.h"

#define kMaxPageCountForRow 20
#define kCollapseAnimationDuration 0.3


@interface MMListPaperStackView (Protected) <UITextFieldDelegate, UIGestureRecognizerDelegate, MMFullWidthListButtonDelegate>

@property (nonatomic, strong) NSString* currentViewMode;

- (CGRect)frameForListViewForPage:(MMPaperView*)page;

- (CGRect)frameForAddPageButton;

@end


@implementation MMCollapsableStackView {
    UIButton* expandButton;
    MMContinuousSwipeGestureRecognizer* deleteGesture;
    CGFloat squishFactor;
    CGFloat initialAdjustment;
    MMTrashButton* deleteRowButton;
    MMShareButton* shareRowButton;

    MMConfirmDeleteStackButton* deleteConfirmationPlaceholder;
    MMEmptyStackButton* emptyStackRowPlaceholder;
    MMImportingPDFListButton* importingPDFListButton;
    MMDecryptPDFStackButton* unlockPDFListButton;

    MMArrowView* collapseNoticeArrow;
    UILabel* collapseNoticeMessage;

    MMShareButton* shareStackButton;
    MMCollapseButton* collapseStackButton;

    BOOL cancelImport;

    NSOperationQueue* importOperationQueue;

    MMPDF* pdfToDecrypt;
    void (^finishDecryptingPDFBlock)();
}

@dynamic stackDelegate;
@synthesize stackNameField;

+ (CGRect)shareStackButtonFrame {
    return CGRectMake([UIScreen screenWidth] - kWidthOfSidebar, 6, kWidthOfSidebarButton, kWidthOfSidebarButton);
}

+ (CGRect)collapseStackButtonFrame {
    return CGRectTranslate([MMCollapsableStackView shareStackButtonFrame], -kWidthOfSidebarButton - kWidthOfSidebarButtonBuffer, 0);
}

- (instancetype)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid {
    if (self = [super initWithFrame:frame andUUID:_uuid]) {
        collapseNoticeArrow = [[MMArrowView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 150, -100, 80, 80)];
        collapseNoticeArrow.alpha = 0;
        [self addSubview:collapseNoticeArrow];

        importOperationQueue = [[NSOperationQueue alloc] init];
        importOperationQueue.maxConcurrentOperationCount = 4;
        importOperationQueue.name = @"importOperationQueue";

        collapseNoticeMessage = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 80, -50, CGRectGetWidth(self.bounds) / 2 + 40, 20)];
        collapseNoticeMessage.text = @"Pull Down to Collapse Pages";
        [collapseNoticeMessage sizeToFit];
        collapseNoticeMessage.center = CGPointTranslate(collapseNoticeArrow.center, CGRectGetMidX(collapseNoticeMessage.bounds) + 40, 0);
        [self addSubview:collapseNoticeMessage];

        expandButton = [[UIButton alloc] initWithFrame:self.bounds];
        expandButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [expandButton addTarget:self action:@selector(tapToExpandToListMode:) forControlEvents:UIControlEventTouchUpInside];
        expandButton.hidden = YES;
        [self addSubview:expandButton];

        deleteGesture = [[MMContinuousSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGesture:)];
        deleteGesture.delegate = self;
        deleteGesture.angleBuffer = 30;
        deleteGesture.enabled = NO;
        [self addGestureRecognizer:deleteGesture];

        CGFloat nameSpace = 40;
        CGFloat buffer = [MMListPaperStackView bufferWidth];
        CGFloat rowHeight = [MMListPaperStackView rowHeight] + 2 * buffer;
        CGFloat deleteButtonWidth = 80;
        CGRect deleteRect = CGRectMake(self.bounds.size.width - 2 * buffer - deleteButtonWidth, roundf(nameSpace + (rowHeight - nameSpace) / 2 - deleteButtonWidth) + .5, deleteButtonWidth, deleteButtonWidth);
        deleteRowButton = [[MMTrashButton alloc] initWithFrame:deleteRect];
        [deleteRowButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        deleteRowButton.alpha = 0;
        [self addSubview:deleteRowButton];

        CGRect shareRect = CGRectTranslate(deleteRect, 0, 80);
        shareRowButton = [[MMShareButton alloc] initWithFrame:shareRect];
        [shareRowButton addTarget:self action:@selector(shareStackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        shareRowButton.alpha = 0;
        shareRowButton.topBgColor = deleteRowButton.backgroundColor;
        shareRowButton.bottomBgColor = deleteRowButton.backgroundColor;
        shareRowButton.borderColor = deleteRowButton.borderColor;
        shareRowButton.arrowColor = [UIColor darkGrayColor];
        [self addSubview:shareRowButton];

        CGRect confirmationRect = CGRectMake(0, 60, self.bounds.size.width, rowHeight - 60);

        deleteConfirmationPlaceholder = [[MMConfirmDeleteStackButton alloc] initWithFrame:confirmationRect];
        deleteConfirmationPlaceholder.delegate = self;
        [self addSubview:deleteConfirmationPlaceholder];

        emptyStackRowPlaceholder = [[MMEmptyStackButton alloc] initWithFrame:confirmationRect];
        emptyStackRowPlaceholder.delegate = self;
        [self addSubview:emptyStackRowPlaceholder];

        importingPDFListButton = [[MMImportingPDFListButton alloc] initWithFrame:confirmationRect];
        importingPDFListButton.delegate = self;
        [self addSubview:importingPDFListButton];

        unlockPDFListButton = [[MMDecryptPDFStackButton alloc] initWithFrame:confirmationRect];
        unlockPDFListButton.delegate = self;
        [self addSubview:unlockPDFListButton];

        CGRect nameFieldFrame = CGRectWithHeight([self bounds], 50);
        nameFieldFrame = CGRectTranslate(nameFieldFrame, 0, 10);
        nameFieldFrame = CGRectInset(nameFieldFrame, [MMListPaperStackView bufferWidth], 10);
        nameFieldFrame.size.width -= 100;
        stackNameField = [[MMColoredTextField alloc] initWithFrame:nameFieldFrame];
        stackNameField.font = [UIFont systemFontOfSize:24];
        stackNameField.returnKeyType = UIReturnKeyDone;
        stackNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        stackNameField.delegate = self;
        [self addSubview:stackNameField];

        shareStackButton = [[MMShareButton alloc] initWithFrame:[MMCollapsableStackView shareStackButtonFrame]];
        shareStackButton.delegate = self;
        [shareStackButton addTarget:self action:@selector(shareStackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareStackButton];

        collapseStackButton = [[MMCollapseButton alloc] initWithFrame:[MMCollapsableStackView collapseStackButtonFrame]];
        collapseStackButton.delegate = self;
        [collapseStackButton addTarget:self action:@selector(collapseStackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:collapseStackButton];
    }
    return self;
}

- (CGRect)rectForColorConsideration {
    CGRect targetRect = [stackNameField frame];
    targetRect.size = [stackNameField sizeThatFits:targetRect.size];
    return targetRect;
}

- (void)setNameColor:(UIColor*)color animated:(BOOL)animated {
    [stackNameField setTintColor:color animated:animated];
}

- (void)setCurrentViewMode:(NSString*)currentViewMode {
    [super setCurrentViewMode:currentViewMode];
    deleteGesture.enabled = [self isShowingCollapsedView];
}

- (NSArray*)findPagesInVisibleRowsOfListView {
    if ([self.stackDelegate isShowingCollapsedView]) {
        // if we're collapsed, then we want to show the same pages
        // that would appear in our row view
        return [self pagesToAlignForRowView];
    } else {
        return [super findPagesInVisibleRowsOfListView];
    }
}

- (BOOL)isPerfectlyAlignedIntoRow {
    return squishFactor == 0 && !unlockPDFListButton.alpha && !importingPDFListButton.alpha;
}

- (BOOL)isCurrentlyHandlingImport {
    return unlockPDFListButton.alpha || importingPDFListButton.alpha;
}

- (void)cancelPendingConfirmationsAndResetToRow {
    [self cancelPendingConfirmationsAndResetToRowQuickly:NO];
}

- (void)cancelPendingConfirmationsAndResetToRowQuickly:(BOOL)quickly {
    if (![self isPerfectlyAlignedIntoRow]) {
        deleteGesture.enabled = YES;
        squishFactor = .15;
        [self finishSwipeToDelete:!quickly sendingDelegateNotifications:NO];
    }
}

#pragma mark - MMEditableStackView

- (void)loadStacksFromDiskIntoListViewIgnoringMeta:(NSArray*)meta {
    [super loadStacksFromDiskIntoListViewIgnoringMeta:meta];
    [self refreshNameFromStackManager];
}

- (void)refreshNameFromStackManager {
    stackNameField.text = self.stackManager.name;
    emptyStackRowPlaceholder.prompt = [NSString stringWithFormat:@"There are no pages in %@", stackNameField.text];
}

#pragma mark - Actions

- (void)ensureAtLeastPagesInStack:(NSInteger)numberOfPages {
    [self ensureAtLeast:3 pagesInStack:self.visibleStackHolder];

    if ([self isShowingCollapsedView]) {
        [self organizePagesIntoSingleRowAnimated:NO];

        for (MMPaperView* page in [[self visibleStackHolder] subviews]) {
            page.alpha = 0;
            page.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(.9, .9), -40, 0);
        }

        CGFloat delay = 0;
        [UIView animateWithDuration:.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            emptyStackRowPlaceholder.alpha = 0;
        } completion:nil];

        for (MMPaperView* page in [[self visibleStackHolder] subviews]) {
            [UIView animateWithDuration:.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                page.alpha = 1;
                page.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[page uuid] hash]));
            } completion:nil];
            delay += .1;
        }
    }
}

- (void)tapToExpandToListMode:(UIButton*)button {
    if ([self.stackDelegate isAllowedToInteractWithStack:self.uuid]) {
        if ([self isPerfectlyAlignedIntoRow]) {
            [[self stackDelegate] didAskToSwitchToStack:[self uuid] animated:YES viewMode:kViewModeList];
        } else if (deleteRowButton.alpha) {
            [self cancelPendingConfirmationsAndResetToRowQuickly:YES];
            [[self stackDelegate] isNotGoingToDeleteStack:[self uuid]];
        }
    }
}

- (void)collapseStackButtonTapped:(UIButton*)_button {
    [[self stackDelegate] mightAskToCollapseStack:[self uuid]];
    [[self stackDelegate] didAskToCollapseStack:[self uuid] animated:YES];
}

- (void)shareStackButtonTapped:(UIButton*)_button {
    [self cancelAllGestures];
    [[visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [self.stackDelegate didAskToExportStack:self.uuid];
    [self.stackDelegate.shareStackSidebar setReferenceButtonFrame:[_button convertRect:_button.bounds toView:nil]];
    [self.stackDelegate.shareStackSidebar show:YES];
}

- (void)showUIToPrepareForImportingPDF:(MMPDFInboxItem*)pdfDoc onComplete:(void (^)())completionBlock {
    [self organizePagesIntoSingleRowAnimated:NO];
    emptyStackRowPlaceholder.alpha = 0;
    importingPDFListButton.alpha = 1;

    [importingPDFListButton setPrompt:@"Importing PDF..."];

    if ([pdfDoc.pdf isEncrypted]) {
        importingPDFListButton.alpha = 0;
        unlockPDFListButton.alpha = 1;

        pdfToDecrypt = pdfDoc.pdf;
        finishDecryptingPDFBlock = completionBlock;
    } else {
        completionBlock(pdfDoc);
    }
}

- (void)importAllPagesFromPDFInboxItem:(MMPDFInboxItem*)pdfDoc fromSourceApplication:(NSString*)sourceApplication onComplete:(void (^)(BOOL success))completionBlock {
    if ([self isShowingCollapsedView]) {
        if ([pdfDoc.pdf.title length]) {
            self.stackManager.name = pdfDoc.pdf.title;
            [self refreshNameFromStackManager];
        }

        cancelImport = NO;
        [self organizePagesIntoSingleRowAnimated:NO];
        __block CGFloat delay = 0;
        emptyStackRowPlaceholder.alpha = 0;
        importingPDFListButton.alpha = 1;

        [importingPDFListButton setPrompt:[NSString stringWithFormat:@"Importing PDF Page %ld / %ld", (long)1, (long)pdfDoc.pdf.pageCount]];

        NSIndexSet* pageSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [pdfDoc pageCount])];
        MMPDFAssetGroup* pdfAlbum = [[MMPDFAssetGroup alloc] initWithInboxItem:pdfDoc];
        NSMutableArray* displayAssets = [NSMutableArray array];
        NSMutableArray* pages = [NSMutableArray array];
        @autoreleasepool {
            [pdfAlbum loadPhotosAtIndexes:pageSet usingBlock:^(MMDisplayAsset* asset, NSUInteger index, BOOL* stop) {
                [displayAssets addObject:asset];
                MMExportablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:hiddenStackHolder.bounds];
                [pages addObject:page];
                page.delegate = self;
            }];
        }


        void (^finishedImportingAllPages)() = ^{
            if (cancelImport) {
                if (completionBlock) {
                    completionBlock(NO);
                }
                return;
            }

            NSArray<MMExportablePaperView*>* allPages = [[visibleStackHolder subviews] arrayByAddingObjectsFromArray:[[hiddenStackHolder subviews] reversedArray]];
            [self organizePagesIntoSingleRowAnimated:NO];

            [UIView animateWithDuration:.2 animations:^{
                importingPDFListButton.alpha = 0;
            }];

            for (NSInteger pageIndex = 0; pageIndex < [allPages count]; pageIndex++) {
                MMPaperView* page = allPages[pageIndex];

                if (pageIndex < kMaxPageCountForRow) {
                    page.alpha = 0;
                    page.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(.9, .9), -40, 0);

                    void (^animationCompletionBlock)(BOOL) = nil;

                    if (pageIndex == [allPages count] - 1 || pageIndex == kMaxPageCountForRow - 1) {
                        // last page
                        animationCompletionBlock = ^(BOOL finished) {
                            [self saveStacksToDisk];
                            if (completionBlock) {
                                completionBlock(YES);
                            }
                        };
                    }

                    [UIView animateWithDuration:.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                        page.alpha = 1;
                        page.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[page uuid] hash]));
                    } completion:animationCompletionBlock];
                    delay += .1;
                } else {
                    page.alpha = 1;
                }
            }
        };


        __block NSInteger totalImportedPages = 0;
        void (^updateImportProgressLabel)() = ^{
            totalImportedPages++;
            [importingPDFListButton setPrompt:[NSString stringWithFormat:@"Importing PDF Page %ld / %ld", (long)totalImportedPages, (long)pdfDoc.pdf.pageCount]];
        };


        MMBlockOperation* finalBlock = [[MMBlockOperation alloc] initWithBlock:^{
            if (cancelImport) {
                if (completionBlock) {
                    completionBlock(NO);
                }
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSInteger index = 0; index < [pages count]; index++) {
                    MMExportablePaperView* page = pages[index];
                    [page saveToDisk:nil];

                    // move page to end
                    if ([self.visibleStackHolder.subviews count] == 0) {
                        [self.visibleStackHolder pushSubview:page];
                    } else {
                        [self.hiddenStackHolder insertSubview:page atIndex:0];
                    }

                    page.alpha = 0;

                    if (index < kMaxPageCountForRow) {
                        if (index == 0) {
                            [page loadCachedPreviewAndDecompressImmediately:YES];
                        } else {
                            [page loadCachedPreview];
                        }
                    } else {
                        [page unloadCachedPreview];
                    }
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), finishedImportingAllPages);
            });
        }];

        CGSize thumbSize = hiddenStackHolder.bounds.size;
        thumbSize.width = floorf(thumbSize.width / 2);
        thumbSize.height = floorf(thumbSize.height / 2);

        for (NSInteger index = 0; index < [pages count]; index++) {
            MMBlockOperation* blockOp = [[MMBlockOperation alloc] initWithBlock:^{
                if (cancelImport) {
                    // don't call completion block here,
                    // we'll call it in the final block that
                    // depends on these
                    return;
                }

                dispatch_async(dispatch_get_main_queue(), updateImportProgressLabel);

                MMDisplayAsset* asset = displayAssets[index];
                MMBackgroundedPaperView* page = pages[index];
                NSURL* assetURL = [asset fullResolutionURL];

                UIImage* thumbImageToImport = [asset aspectThumbnailWithMaxPixelSize:CGSizeMaxDim(thumbSize)];
                [NSFileManager ensureDirectoryExistsAtPath:[page pagesPath]];

                [MMExportablePaperView writeThumbnailImagesToDisk:thumbImageToImport thumbnailPath:[page thumbnailPath] scrappedThumbnailPath:[page scrappedThumbnailPath]];

                [page saveOriginalBackgroundTextureFromURL:assetURL];
            }];
            [finalBlock addDependency:blockOp];
            [importOperationQueue addOperation:blockOp];
        }

        [importOperationQueue addOperation:finalBlock];
    }

    if ([pdfDoc pageCount] == 0 && completionBlock) {
        completionBlock(NO);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    if ([scrollView isDragging] && (scrollView.contentOffset.y < -50)) {
        [[self stackDelegate] mightAskToCollapseStack:[self uuid]];
    }

    // update the arrow
    [collapseNoticeMessage setTextColor:stackNameField.textColor];
    [collapseNoticeArrow setBackgroundColor:stackNameField.textColor];

    CGFloat y = MIN(MAX(0, -scrollView.contentOffset.y), 100);
    CGRect initialFrame = CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetMidX(collapseNoticeMessage.bounds) - 40, -80, 80, 80);

    CGFloat updatedAlpha = y / 100.0;

    if (updatedAlpha >= 1.0 && collapseNoticeArrow.alpha < 1.0) {
        [collapseNoticeArrow bounce];
    }

    collapseNoticeArrow.alpha = updatedAlpha;
    y = MAX(0, -scrollView.contentOffset.y - 100);
    collapseNoticeArrow.frame = CGRectOffset(initialFrame, 0, -y);
    collapseNoticeMessage.center = CGPointTranslate(collapseNoticeArrow.center, CGRectGetMidX(collapseNoticeMessage.bounds) + 40, 0);

    [super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -100) {
        // Need to turn off bouncing so that the bounce animation from releasing the over-scroll
        // doesn't occur. otherwise it interferes with the row animation.
        self.bounces = NO;
        // immediately set the content offset to zero, and adjust the position of the scroll view
        // so that the pages stay visibly in the same place. The animation into the row will
        // resize and reposition the scrollview as part of the animation, so we only need to make
        // sure that our initial position + size look correct at the start of the animation.
        CGRect fr = self.frame;
        fr.origin.y = -scrollView.contentOffset.y;
        self.frame = fr;
        self.contentOffset = CGPointZero;

        // when transitioning from list view, we need to save our current offset so that re-entering
        // the list will begin at the top.
        initialScrollOffsetFromTransitionToListView = CGPointZero;
        pagesThatWillBeVisibleAfterTransitionToListView = [self findPagesInVisibleRowsOfListViewGivenOffset:CGPointZero];
        [[self stackDelegate] didAskToCollapseStack:[self uuid] animated:YES];
    } else {
        [[self stackDelegate] didNotAskToCollapseStack:[self uuid]];
    }

    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

#pragma mark - Helper

- (NSArray*)pagesToAlignForRowView {
    NSMutableArray* pagesToAlignIntoRow = [NSMutableArray array];
    if ([[visibleStackHolder subviews] count] < kMaxPageCountForRow) {
        [pagesToAlignIntoRow addObjectsFromArray:[visibleStackHolder subviews]];
    } else if ([[visibleStackHolder subviews] count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[visibleStackHolder subviews] subarrayWithRange:NSMakeRange(0, kMaxPageCountForRow)]];
    }
    if ([[hiddenStackHolder subviews] count] < kMaxPageCountForRow - [pagesToAlignIntoRow count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[hiddenStackHolder subviews] reversedArray]];
    } else if ([[visibleStackHolder subviews] count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[[hiddenStackHolder subviews] reversedArray] subarrayWithRange:NSMakeRange(0, kMaxPageCountForRow - [pagesToAlignIntoRow count])]];
    }
    return pagesToAlignIntoRow;
}

- (CGFloat)collapsedViewButtonRotation {
    if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait) {
        return 0;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft) {
        return -M_PI_2;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight) {
        return M_PI_2;
    } else {
        return M_PI;
    }
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    CheckMainThread;

    [super didRotateToIdealOrientation:orientation];

    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self collapsedViewButtonRotation]);
        shareStackButton.rotation = [self collapsedViewButtonRotation];
        shareStackButton.transform = rotationTransform;
        collapseStackButton.rotation = [self collapsedViewButtonRotation];
        collapseStackButton.transform = rotationTransform;
        deleteRowButton.rotation = [self collapsedViewButtonRotation];
        deleteRowButton.transform = rotationTransform;
        shareRowButton.rotation = [self collapsedViewButtonRotation];
        shareRowButton.transform = rotationTransform;
    }];
}

#pragma mark - Animate into row form

- (BOOL)isIPadPro {
    return [UIScreen screenWidth] > 768;
}

- (CGRect)frameForAddPageButton {
    CGRect r = [super frameForAddPageButton];
    return CGRectTranslate(r, 0, [self isIPadPro] ? 30 : 40);
}

- (CGRect)frameForListViewForPage:(MMPaperView*)page {
    CGRect r = [super frameForListViewForPage:page];
    return CGRectTranslate(r, 0, [self isIPadPro] ? 30 : 40);
}

- (CGFloat)contentHeightForAllPages {
    return [super contentHeightForAllPages] + ([self isIPadPro] ? 30 : 40);
}

- (CGRect)targetFrameInRowForPage:(MMPaperView*)aPage givenAllPages:(NSArray*)pagesToAlignIntoRow {
    // now we're going to animate all of the pages into a single row.
    // to do that, we find the first + list frames for pages, and equally
    // spread the pages between those two frames
    CGRect firstFrame = [self frameForIndexInList:0];
    CGRect lastFrame = [self frameForIndexInList:kNumberOfColumnsInListView - 1];
    NSInteger minimumNumberOfPagesForSpacing = MAX(12, [pagesToAlignIntoRow count]) - 1;
    NSInteger indexInList = [pagesToAlignIntoRow indexOfObject:aPage];
    CGRect targetFrame = firstFrame;
    targetFrame.origin.x += (lastFrame.origin.x - firstFrame.origin.x) * ((CGFloat)indexInList / minimumNumberOfPagesForSpacing);
    targetFrame = CGRectTranslate(targetFrame, 0, 20);
    return targetFrame;
}

/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated {
    if ([self isShowingPageView]) {
        [self immediatelyTransitionToListView];
    }

    NSArray* pagesToAlignIntoRow = [self pagesToAlignForRowView];
    [self setCurrentViewMode:kViewModeCollapsed];

    //
    // first, hide all pages that won't be visible during the row animation.
    void (^step1)(void) = ^{
        // Move the visible stack above the hidden stack. During list/page views, we want
        // the pages from the hidden stack to be visible above the pages in the visible stack,
        // but for the collapsed row we want the hidden pages to be lined up behind the top most page.
        visibleStackHolder.layer.zPosition = 1;

        [pagesToAlignIntoRow enumerateObjectsUsingBlock:^(MMPaperView* _Nonnull aPage, NSUInteger idx, BOOL* _Nonnull stop) {
            aPage.layer.zPosition = [pagesToAlignIntoRow count] - idx;
        }];
        //
        // immediately hide all of the pages that we won't be animating
        for (MMEditablePaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            if ([pagesToAlignIntoRow containsObject:aPage]) {
                // we'll animate these in step 2
                [[MMPageCacheManager sharedInstance] loadPageThumbnailToCache:aPage];
            } else {
                // we already have the last visible page, we're going to
                // hide all other pages during the animation, then re-show
                // them in their correct positions afterwards
                aPage.hidden = YES;
            }
        }

        // when we're in row mode, we don't let the user scroll at all, we become
        // a static button that can be tapped to expand. Scrolling the collapsed lists
        // is handled in a different scroll view in MMLooseLeafViewController.
        [self setScrollEnabled:NO];
        [expandButton setHidden:NO];
    };

    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the row view
    void (^step2)(void) = ^{
        // don't show the notice when animating into a row
        collapseNoticeMessage.hidden = YES;
        collapseNoticeArrow.hidden = YES;

        // animate all of the pages in the row to their final location.
        // we also rotate the pages slightly so that the view isn't
        // so sterile and boring.
        for (NSInteger index = 0; index < [pagesToAlignIntoRow count]; index++) {
            MMPaperView* aPage = pagesToAlignIntoRow[index];
            // a UIView's frame takes into account its transform, but our
            // frames are set assuming an identity transform. let's enforce
            // the identity before setting the frame to make this explicit.
            aPage.transform = CGAffineTransformIdentity;
            aPage.frame = [self targetFrameInRowForPage:aPage givenAllPages:pagesToAlignIntoRow];
            aPage.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[aPage uuid] hash]));
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;
        addPageButtonInListView.alpha = 0;
        deleteConfirmationPlaceholder.alpha = 0;
        unlockPDFListButton.alpha = pdfToDecrypt ? 1 : 0;
        emptyStackRowPlaceholder.alpha = [pagesToAlignIntoRow count] == 0 && !pdfToDecrypt;
        deleteRowButton.alpha = 0;
        shareRowButton.alpha = 0;
        shareStackButton.alpha = 0;
        collapseStackButton.alpha = 0;
        stackNameField.alpha = 1;
        squishFactor = 0;
        [self setContentOffset:CGPointZero];
    };

    //
    // all of our pages are organized into a single row.
    //
    void (^step3)(BOOL finished) = ^(BOOL finished) {
        // ensure sane default for content size
        [self setContentSize:CGSizeMake([UIScreen screenWidth], [UIScreen screenHeight])];
        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;
        addPageButtonInListView.alpha = 0;

        [pagesToAlignIntoRow enumerateObjectsUsingBlock:^(MMPaperView* _Nonnull aPage, NSUInteger idx, BOOL* _Nonnull stop) {
            // The smooth border forces us to rasterize the page layer, so we want
            // to only set this to YES during page row mode, but never during list/page mode
            [aPage setSmoothBorder:YES];
        }];

        [[NSUserDefaults standardUserDefaults] setObject:kViewModeCollapsed forKey:kCurrentViewMode];
    };

    step1();

    if (animated) {
        // ok, animate all the views in the visible stack!
        [UIView animateWithDuration:kCollapseAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:step2
                         completion:step3];
    } else {
        step2();
        step3(YES);
    }
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
- (void)organizePagesIntoListAnimated:(BOOL)animated {
    NSArray* pagesToAnimateIntoRow = [self pagesToAlignForRowView];

    //
    // first, find all pages behind the first full scale
    // page, and just move them immediately
    //
    // this helps pretty dramatically with the animation
    // performance.
    //
    // also, turn off gestures
    void (^step1)(void) = ^{
        expandButton.hidden = YES;
        //
        // immediately hide all of the pages that we won't be animating
        for (MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            // unhide all pages that were hidden from being collapsed into a single row
            aPage.hidden = NO;
            if (![pagesToAnimateIntoRow containsObject:aPage]) {
                aPage.transform = CGAffineTransformIdentity;
                aPage.frame = [self frameForListViewForPage:aPage];
            }
        }
        // update the location of the add button in case any pages
        // were deleted/added since we last showed the stack in list mode
        [self moveAddButtonToTop];
    };

    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for (MMPaperView* aPage in pagesToAnimateIntoRow) {
            // these views we're animating into place
            aPage.transform = CGAffineTransformIdentity;
            aPage.frame = [self frameForListViewForPage:aPage];
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        // fade in the add/tutorial buttons
        listViewTutorialButton.alpha = 1;
        listViewFeedbackButton.alpha = 1;
        addPageButtonInListView.alpha = 1;
        shareStackButton.alpha = 1;
        collapseStackButton.alpha = 1;
        stackNameField.alpha = 1;
        [self setButtonsVisible:NO animated:NO];
    };

    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step3)(BOOL finished) = ^(BOOL finished) {
        // show the notice only in list mode
        collapseNoticeMessage.hidden = NO;
        collapseNoticeArrow.hidden = NO;

        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that the scrollview works.
        for (MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            // gestures aren't allowed in row view
            [aPage disableAllGestures];
            aPage.layer.zPosition = 0;
            [aPage setSmoothBorder:NO];
        }
        // set our content height/offset for the pages
        [self setContentOffset:CGPointZero animated:NO];
        [self setContentSize:CGSizeMake([UIScreen screenWidth], [self contentHeightForAllPages])];
        [self finishUITransitionToListView];
        [self moveAddButtonToTop];

        // in list and page mode, the hidden stack pages should show above
        // the visible stack pages
        visibleStackHolder.layer.zPosition = 0;

        // now that we're back into list mode, we need to re-enable scrolling + bounce
        [self setBounces:YES];
        [self setScrollEnabled:YES];

        // update our view mode
        [[NSUserDefaults standardUserDefaults] setObject:kViewModeList forKey:kCurrentViewMode];
    };

    step1();

    if (animated) {
        // ok, animate all the views in the visible stack!
        [UIView animateWithDuration:kCollapseAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:step2
                         completion:step3];
    } else {
        step2();
        step3(YES);
    }
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

- (void)immediatelyTransitionToPageViewAnimated:(BOOL)animated {
    if (animated && CGPointEqualToPoint(self.contentOffset, CGPointZero)) {
        [UIView animateWithDuration:.2 animations:^{
            shareStackButton.alpha = 0;
            collapseStackButton.alpha = 0;
            stackNameField.alpha = 0;
        }];
    } else {
        shareStackButton.alpha = 0;
        collapseStackButton.alpha = 0;
        stackNameField.alpha = 0;
    }

    [super immediatelyTransitionToPageViewAnimated:animated];
}

- (void)finishedScalingReallySmall:(MMPaperView*)page animated:(BOOL)animated {
    [super finishedScalingReallySmall:page animated:animated];
    if (CGPointEqualToPoint(initialScrollOffsetFromTransitionToListView, CGPointZero)) {
        if (animated) {
            [UIView animateWithDuration:.3 animations:^{
                shareStackButton.alpha = 1;
                collapseStackButton.alpha = 1;
                stackNameField.alpha = 1;
            }];
        } else {
            shareStackButton.alpha = 1;
            collapseStackButton.alpha = 1;
            stackNameField.alpha = 1;
        }
    }
}

- (void)finishUITransitionToListView {
    [super finishUITransitionToListView];
    shareStackButton.alpha = 1;
    collapseStackButton.alpha = 1;
    stackNameField.alpha = 1;
}


#pragma mark - MMStretchPageGestureRecognizerDelegate

- (void)didPickUpAPageInListView:(MMLongPressFromListViewGestureRecognizer*)gesture {
    [super didPickUpAPageInListView:gesture];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:.2 animations:^{
            shareStackButton.alpha = 0;
            collapseStackButton.alpha = 0;
            stackNameField.alpha = 0;
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

#pragma mark - Delete Inbox Items

- (void)deleteGesture:(MMContinuousSwipeGestureRecognizer*)sender {
    if (![[self stackDelegate] isAllowedToInteractWithStack:[self uuid]] ||
        [[self pagesToAlignForRowView] count] == 0) {
        // cancel the gesture
        [sender setEnabled:NO];
        [sender setEnabled:YES];
        [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        // notify other stacks to cancel their delete gesture if any
        // also, don't let the user swipe to delete and scroll the stacks at the same time
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:0];
        deleteConfirmationPlaceholder.alpha = 0;
        emptyStackRowPlaceholder.alpha = 0;

        initialAdjustment = squishFactor;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect firstFrame = [self frameForIndexInList:0];
        CGRect lastFrame = [self frameForIndexInList:kNumberOfColumnsInListView - 1];
        CGFloat amount = -sender.distanceSinceBegin.x; // negative, because we're moving left
        CGFloat updatedSquish = initialAdjustment + amount / (CGRectGetMidX(lastFrame) - CGRectGetMidX(firstFrame));
        [self adjustForDelete:updatedSquish withTranslate:0];
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:MAX(0, updatedSquish - .3) * 1.8];
        deleteRowButton.alpha = MIN(.2, MAX(0, updatedSquish)) / .2;
        shareRowButton.alpha = deleteRowButton.alpha;
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        // enable scrolling stack list
        [self finishSwipeToDelete:NO sendingDelegateNotifications:YES];
    }
}


// must be called after adjustForDelete
- (BOOL)finishSwipeToDelete:(BOOL)longerDuration sendingDelegateNotifications:(BOOL)sendDelegateNotifications {
    if (squishFactor < .2) {
        // bounce back to zero and hide delete button
        [UIView animateWithDuration:longerDuration ? .4 : .2 animations:^{
            CGFloat bounce = ABS(squishFactor * .2);
            [self adjustForDelete:(squishFactor < 0) ? bounce : -bounce withTranslate:0];
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
            deleteRowButton.alpha = 0;
            shareRowButton.alpha = 0;
            deleteConfirmationPlaceholder.alpha = 0;
            emptyStackRowPlaceholder.alpha = [[self pagesToAlignForRowView] count] == 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:longerDuration ? .2 : .1 animations:^{
                [self adjustForDelete:0 withTranslate:0];
            }];
        }];
        return NO;
    } else if (squishFactor > .6) {
        // bypass tapping the delete button and just
        // delete immediately
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self adjustForDelete:1 withTranslate:-250];
            deleteRowButton.alpha = 0;
            shareRowButton.alpha = 0;
            deleteConfirmationPlaceholder.alpha = 1;
            emptyStackRowPlaceholder.alpha = 0;
        } completion:nil];
        [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
        } completion:nil];
        deleteGesture.enabled = NO;
        return YES;
    } else {
        // bounce to show delete button
        CGFloat targetToShowButtons = .2;
        [UIView animateWithDuration:.2 animations:^{
            CGFloat bounce = MIN(ABS(targetToShowButtons - squishFactor) * .2, 20);
            [self adjustForDelete:(squishFactor < targetToShowButtons) ? (targetToShowButtons + bounce) : (targetToShowButtons - bounce) withTranslate:0];
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
            deleteRowButton.alpha = 1.0;
            shareRowButton.alpha = 1.0;
            deleteConfirmationPlaceholder.alpha = 0;
            emptyStackRowPlaceholder.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                [self adjustForDelete:targetToShowButtons withTranslate:0];
            }];
        }];
        return NO;
    }
}

- (void)adjustForDelete:(CGFloat)adjustment withTranslate:(CGFloat)xTranslate {
    if ([self.layer.animationKeys count]) {
        [self.layer removeAllAnimations];
    }

    squishFactor = MAX(-0.2, adjustment);
    CGFloat easedOut = adjustment;
    if (easedOut < 0) {
        easedOut = MAX(easedOut, -0.8);
        easedOut = MAX(easedOut + .8, 0) / .8;
        easedOut = 1 - easedOut * easedOut * easedOut;
        easedOut = easedOut * -.2;
    }

    [self setClipsToBounds:squishFactor == 0];
    [deleteRowButton setEnabled:squishFactor > 0];
    [shareRowButton setEnabled:squishFactor > 0];

    CGFloat alphaForDelete = adjustment - .5;
    alphaForDelete = MAX(alphaForDelete, 0);
    alphaForDelete /= .4;
    alphaForDelete = MIN(alphaForDelete, 1.0);
    //    deleteButton.alpha = alphaForDelete;

    NSArray* pagesToAlign = [self pagesToAlignForRowView];

    if ([pagesToAlign count]) {
        CGRect frameAtStart = [self targetFrameInRowForPage:pagesToAlign[0] givenAllPages:pagesToAlign];

        for (int i = 0; i < [pagesToAlign count]; i++) {
            MMPaperView* aPage = pagesToAlign[i];
            CGFloat ix = CGRectGetMidX([self targetFrameInRowForPage:aPage givenAllPages:pagesToAlign]);
            CGFloat fx = CGRectGetMidX(frameAtStart) - 120 + i * 4;
            CGFloat diff = fx - ix;
            CGFloat x = ix + diff * easedOut;

            aPage.center = CGPointMake(x + xTranslate, CGRectGetMidY(frameAtStart) + (RandomMod(i, 80) - 40) * easedOut);

            aPage.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[aPage uuid] hash]) + easedOut * 5 * RandomPhotoRotation([[aPage uuid] hash]));
        }
    }
}

- (IBAction)deleteButtonTapped:(id)sender {
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self adjustForDelete:.9 withTranslate:0];
    } completion:nil];
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:1.0];
        deleteRowButton.alpha = 0;
        shareRowButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            [self adjustForDelete:1.0 withTranslate:-250];
        } completion:nil];
    }];
    [UIView animateWithDuration:.3 delay:.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        deleteConfirmationPlaceholder.alpha = 1;
        emptyStackRowPlaceholder.alpha = 0;
    } completion:nil];
    deleteGesture.enabled = NO;
}

#pragma mark - MMFullWidthListButtonDelegate

- (void)didTapLeftInFullWidthButton:(MMFullWidthListButton*)button {
    if (button == importingPDFListButton || button == unlockPDFListButton) {
        cancelImport = YES;
    }
    deleteGesture.enabled = YES;
    squishFactor = 0;
    [self.stackDelegate isAskingToDeleteStack:self.uuid];

    if (button == unlockPDFListButton && finishDecryptingPDFBlock) {
        importingPDFListButton.alpha = 1;
        unlockPDFListButton.alpha = 0;
        finishDecryptingPDFBlock();
        finishDecryptingPDFBlock = nil;
        pdfToDecrypt = nil;
    }
}

- (void)didTapRightInFullWidthButton:(MMFullWidthListButton*)button {
    if (button == unlockPDFListButton) {
        if (![pdfToDecrypt attemptToDecrypt:unlockPDFListButton.password]) {
            [unlockPDFListButton bouncePasswordInput];
        }
    } else if (button == deleteConfirmationPlaceholder) {
        deleteGesture.enabled = YES;
        squishFactor = .15;
        [self finishSwipeToDelete:YES sendingDelegateNotifications:YES];
    } else {
        // asking to add three pages
        [self ensureAtLeastPagesInStack:3];
    }

    if (button == unlockPDFListButton && finishDecryptingPDFBlock && ![pdfToDecrypt isEncrypted]) {
        importingPDFListButton.alpha = 1;
        unlockPDFListButton.alpha = 0;
        finishDecryptingPDFBlock();
        finishDecryptingPDFBlock = nil;
        pdfToDecrypt = nil;
    }
}

#pragma mark - Row Animation Helpers

- (void)squashPagesWhenInRowView:(CGFloat)squash withTranslate:(CGFloat)translate {
    if (![[self currentViewMode] isEqualToString:kViewModeCollapsed]) {
        @throw [NSException exceptionWithName:@"CollapsedException" reason:@"Cannot squash pages outside of row view" userInfo:nil];
    }
    [self adjustForDelete:squash withTranslate:translate];
}

- (CGPoint)effectiveRowCenter {
    NSArray* pagesToAlign = [self pagesToAlignForRowView];

    if ([pagesToAlign count]) {
        MMPaperView* firstPage = pagesToAlign[0];
        MMPaperView* lastPage = pagesToAlign[[pagesToAlign count] - 1];
        CGFloat diffx = lastPage.center.x - firstPage.center.x;
        CGFloat diffy = lastPage.center.y - firstPage.center.y;
        return CGPointMake(firstPage.center.x + diffx / 2, firstPage.center.y + diffy / 2);
    } else {
        return CGRectGetMidPoint([self bounds]);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return [self.stackDelegate isAllowedToInteractWithStack:self.uuid];
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
    if ([self isShowingListView]) {
        self.scrollEnabled = NO;
    }
    [self.stackDelegate isBeginningToEditName:self.uuid];
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    self.stackManager.name = textField.text;
    emptyStackRowPlaceholder.prompt = [NSString stringWithFormat:@"There are no pages in %@", stackNameField.text];

    if ([self isShowingListView]) {
        self.scrollEnabled = YES;
    }
    [self.stackDelegate didFinishEditingName:self.uuid];
}

- (void)textFieldDidEndEditing:(UITextField*)textField reason:(UITextFieldDidEndEditingReason)reason {
    if (reason == UITextFieldDidEndEditingReasonCommitted) {
        [self textFieldDidEndEditing:textField];
    }
}

#pragma mark - Animation to show how to move back to collapsed view

- (void)showCollapsedAnimation:(void (^)())onComplete {
    if ([self isShowingListView]) {
        self.userInteractionEnabled = NO;
        [self scrollViewDidScroll:self];

        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentOffset = CGPointMake(0, -100);
            [self scrollViewDidScroll:self];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.contentOffset = CGPointMake(0, -150);
                [self scrollViewDidScroll:self];
                [collapseNoticeArrow bounce];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.contentOffset = CGPointZero;
                    [self scrollViewDidScroll:self];
                } completion:^(BOOL finished) {
                    if (onComplete)
                        onComplete();
                    self.userInteractionEnabled = YES;
                }];
            }];
        }];
    }
}

#pragma mark - Debug Actions

- (void)exportStackToPDF:(void (^)(NSURL* urlToPDF))completionBlock withProgress:(BOOL (^)(NSInteger pageSoFar, NSInteger totalPages))progressBlock {
    JotView* exportJotView = [[JotView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];

    NSMutableArray* allPagePDFs = [NSMutableArray array];

    NSArray<MMExportablePaperView*>* allPages = [[visibleStackHolder subviews] arrayByAddingObjectsFromArray:[[hiddenStackHolder subviews] reversedArray]];

    __block void (^exportTopPageOf)(NSArray<MMExportablePaperView*>* pages);
    exportTopPageOf = ^(NSArray<MMExportablePaperView*>* pages) {
        MMExportablePaperView* page = [pages firstObject];
        BOOL needsLoad = !page.isStateLoaded;
        BOOL needsDrawable = !page.drawableView;

        if (progressBlock([allPagePDFs count], [allPages count])) {
            // check if the user has asked to cancel
            for (NSURL* url in allPagePDFs) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            }
            return;
        }

        if (needsLoad) {
            [page loadStateAsynchronously:NO withSize:exportJotView.pagePtSize andScale:exportJotView.scale andContext:exportJotView.context];
        }

        if (needsDrawable) {
            [page setDrawableView:exportJotView];
        }

        [page exportVisiblePageToPDF:^(NSURL* urlToPDF) {
            if (urlToPDF) {
                [allPagePDFs addObject:urlToPDF];
            }

            if (needsLoad) {
                [page unloadState];
            }

            if (needsDrawable) {
                [page setDrawableView:nil];
            }

            if ([pages count] > 1) {
                exportTopPageOf([pages subarrayWithRange:NSMakeRange(1, [pages count] - 1)]);
            } else {
                exportTopPageOf = nil;

                // make sure our JotView is dead.
                // this will also add it to the trash manager
                [exportJotView invalidate];

                if (progressBlock([allPagePDFs count], [allPages count])) {
                    // check if the user has asked to cancel
                    for (NSURL* url in allPagePDFs) {
                        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                    }
                    return;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    // done! our PDFs for each page are in allPagePDFs.
                    // next is to merge all these into 1 single PDF

                    // Loop variables
                    CGPDFPageRef page;
                    CGRect mediaBox;

                    NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
                    NSURL* pdfURLOutput = [NSURL fileURLWithPath:tmpPagePath];
                    CGContextRef writeContext = CGPDFContextCreateWithURL((CFURLRef)pdfURLOutput, NULL, NULL);

                    // Read the first PDF and generate the output pages
                    for (NSURL* pdfURL in allPagePDFs) {
                        @autoreleasepool {
                            MMPDF* pdf = [[MMPDF alloc] initWithURL:pdfURL];
                            CGPDFDocumentRef pdfRef1 = CGPDFDocumentCreateWithURL((CFURLRef)pdf.urlOnDisk);

                            for (int i = 1; i <= [pdf pageCount]; i++) {
                                @autoreleasepool {
                                    page = CGPDFDocumentGetPage(pdfRef1, i);
                                    mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                                    CGContextBeginPage(writeContext, &mediaBox);
                                    CGContextDrawPDFPage(writeContext, page);
                                    CGContextEndPage(writeContext);
                                }
                            }

                            CGPDFDocumentRelease(pdfRef1);
                        }
                    }

                    // Finalize the output file
                    CGPDFContextClose(writeContext);

                    // Release from memory
                    CGContextRelease(writeContext);

                    // delete per-page PDFs
                    for (NSURL* url in allPagePDFs) {
                        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                    }

                    completionBlock(pdfURLOutput);
                });
            }
        }];
    };

    exportTopPageOf(allPages);
}

@end
