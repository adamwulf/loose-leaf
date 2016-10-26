//
//  MMEditablePaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "MMAllStacksManager.h"
#import "MMScrappedPaperView.h"
#import "MMScrapBubbleButton.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMExportablePaperView.h"
#import "Highlighter.h"
#import "MMMemoryProfileView.h"
#import "MMRulerView.h"
#import "UIView+SubviewStacks.h"
#import "Mixpanel.h"
#import "MMPDFButton.h"
#import <mach/mach_time.h> // for mach_absolute_time() and friends
#import <SafariServices/SafariServices.h>


@implementation MMEditablePaperStackView {
    MMMemoryProfileView* memoryView;

    // this tracks how many times the user has
    // used two fingers with the ruler gesture in
    // a row but didn't actually draw.
    // this way we can bounce the hand button, they're
    // probably trying to use hands.
    NSInteger numberOfRulerGesturesWithoutStroke;
}

@synthesize insertImageButton;
@synthesize shareButton;

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid {
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code

        [[NSFileManager defaultManager] preCacheDirectoryListingAt:[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:self.stackManager.uuid] stringByAppendingPathComponent:@"Pages"]];

        [MMPageCacheManager sharedInstance].drawableView = [[JotView alloc] initWithFrame:self.bounds];

        highlighter = [[Highlighter alloc] init];

        marker = [[Pen alloc] initWithMinSize:4.0 andMaxSize:8.0 andMinAlpha:0.8 andMaxAlpha:1.0];

        pen = [[Pen alloc] init];

        eraser = [[Eraser alloc] init];

        scissor = [[MMScissorTool alloc] init];
        scissor.delegate = self;

        // test code for custom popovers
        // ================================================================================
        //    MMPopoverView* popover = [[MMPopoverView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
        //    [self addSubview:popover];

        //
        // sidebar buttons
        // ================================================================================
        addPageSidebarButton = [[MMPlusButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, (kWidthOfSidebar - kWidthOfSidebarButton) / 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        addPageSidebarButton.delegate = self;
        [addPageSidebarButton addTarget:self action:@selector(addPageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:addPageSidebarButton extendFrame:NO];

        shareButton = [[MMShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, (kWidthOfSidebar - kWidthOfSidebarButton) / 2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        shareButton.delegate = self;
        [self.toolbar addButton:shareButton extendFrame:NO];

        // memory button
        CGRect settingsButtonRect = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, (kWidthOfSidebar - kWidthOfSidebarButton) / 2 + 2 * 60, kWidthOfSidebarButton, kWidthOfSidebarButton);
        settingsButton = [[MMTextButton alloc] initWithFrame:settingsButtonRect andFont:[UIFont systemFontOfSize:20] andLetter:@"!?" andXOffset:2 andYOffset:0];
        settingsButton.delegate = self;
        [settingsButton addTarget:self action:@selector(toggleMemoryView:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.toolbar addButton:settingsButton extendFrame:NO];


        pencilTool = [[MMPencilAndPaletteView alloc] initWithButtonFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar, kWidthOfSidebarButton, kWidthOfSidebarButton) andScreenSize:self.bounds.size];
        [self.toolbar addPencilTool:pencilTool];

        eraserButton = [[MMPencilEraserButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        eraserButton.delegate = self;
        [eraserButton addTarget:self action:@selector(eraserTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:eraserButton extendFrame:NO];

        CGRect scissorButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton);
        scissorButton = [[MMScissorButton alloc] initWithFrame:scissorButtonFrame];
        scissorButton.delegate = self;
        [scissorButton addTarget:self action:@selector(scissorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:scissorButton extendFrame:NO];

        insertImageButton = [[MMImageButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar + 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        insertImageButton.delegate = self;
        [self.toolbar addButton:insertImageButton extendFrame:NO];

        CGRect handButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar + 60 * 5.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        handButton = [[MMHandButton alloc] initWithFrame:handButtonFrame];
        handButton.delegate = self;
        [handButton addTarget:self action:@selector(handTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:handButton extendFrame:NO];

        CGRect rulerButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, kStartOfSidebar + 60 * 6.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        rulerButton = [[MMRulerButton alloc] initWithFrame:rulerButtonFrame];
        rulerButton.delegate = self;
        [rulerButton addTarget:self action:@selector(rulerTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:rulerButton extendFrame:NO];


        undoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton) / 2 - 2 * 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        undoButton.delegate = self;
        [undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        undoButton.reverseArrow = YES;
        [self.toolbar addButton:undoButton extendFrame:YES];

        redoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton) / 2 - 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        redoButton.delegate = self;
        [redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:redoButton extendFrame:YES];

#ifdef DEBUG
        MMTextButton* imageExportButton = [[MMTextButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, self.frame.size.height - 5 * kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton) / 2, kWidthOfSidebarButton, kWidthOfSidebarButton) andFont:[UIFont systemFontOfSize:12] andLetter:@"PNG" andXOffset:0 andYOffset:0];
        imageExportButton.delegate = self;
        [imageExportButton addTarget:self action:@selector(exportAsImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:imageExportButton extendFrame:NO];

        MMPDFButton* pdfExportButton = [[MMPDFButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton) / 2, self.frame.size.height - 4 * kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton) / 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        pdfExportButton.delegate = self;
        [pdfExportButton addTarget:self action:@selector(exportAsPDF:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addButton:pdfExportButton extendFrame:NO];
#endif

        //
        // accelerometer for rotating buttons
        // ================================================================================

        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.multipleTouchEnabled = YES;
        self.bounces = YES;
        self.alwaysBounceHorizontal = NO;
        self.canCancelContentTouches = YES;
        self.clearsContextBeforeDrawing = YES;
        self.clipsToBounds = YES;
        self.delaysContentTouches = NO;


        if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSelectedBrush] isEqualToString:kBrushMarker]) {
            [pencilTool setActiveButton:pencilTool.markerButton];
        } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSelectedBrush] isEqualToString:kBrushHighlighter]) {
            [pencilTool setActiveButton:pencilTool.highlighterButton];
        } else {
            [pencilTool setActiveButton:pencilTool.pencilButton];
        }
        pencilTool.delegate = self;

        pencilTool.selected = YES;
        handButton.selected = YES;

        rulerView = [[MMRulerView alloc] initWithFrame:self.bounds];
        [self addSubview:rulerView];
    }
    return self;
}

static UIWebView* pdfWebView;

- (void)exportAsPDF:(id)sender {
    if (pdfWebView) {
        [pdfWebView removeFromSuperview];
        pdfWebView = nil;
    }
    [[[self visibleStackHolder] peekSubview] exportToPDF:^(NSURL* urlToPDF) {
        if (urlToPDF) {
            // https://openradar.appspot.com/25489061
            // UIPDFPageRenderOperation object %p overreleased while already deallocating; break on objc_overrelease_during_dealloc_error to debug
            pdfWebView = [[UIWebView alloc] initWithFrame:CGRectMake(100, 100, 600, 600)];
            [[pdfWebView layer] setBorderColor:[[UIColor redColor] CGColor]];
            [[pdfWebView layer] setBorderWidth:2];

            NSURLRequest* request = [NSURLRequest requestWithURL:urlToPDF];
            [pdfWebView loadRequest:request];

            [self addSubview:pdfWebView];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [pdfWebView removeFromSuperview];
            pdfWebView = nil;
        });
    }];
}

- (void)exportAsImage:(id)sender {
    if (pdfWebView) {
        [pdfWebView removeFromSuperview];
        pdfWebView = nil;
    }
    [[[self visibleStackHolder] peekSubview] exportToImage:^(NSURL* urlToImage) {
        if (urlToImage) {
            pdfWebView = [[UIWebView alloc] initWithFrame:CGRectMake(100, 100, 600, 600)];
            [[pdfWebView layer] setBorderColor:[[UIColor redColor] CGColor]];
            [[pdfWebView layer] setBorderWidth:2];
            pdfWebView.scalesPageToFit = YES;
            pdfWebView.contentMode = UIViewContentModeScaleAspectFit;

            NSURLRequest* request = [NSURLRequest requestWithURL:urlToImage];
            [pdfWebView loadRequest:request];

            [self addSubview:pdfWebView];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [pdfWebView removeFromSuperview];
            pdfWebView = nil;
        });
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMemoryView:(MMMemoryProfileView*)_memoryView {
    memoryView = _memoryView;
}


- (void)toggleMemoryView:(UIButton*)button {
    memoryView.hidden = !memoryView.hidden;
}

- (int)fullByteSize {
    return [super fullByteSize] + addPageSidebarButton.fullByteSize + shareButton.fullByteSize + settingsButton.fullByteSize + pencilTool.fullByteSize + eraserButton.fullByteSize + scissorButton.fullByteSize + insertImageButton.fullByteSize + handButton.fullByteSize + rulerButton.fullByteSize + undoButton.fullByteSize + redoButton.fullByteSize + rulerView.fullByteSize;
}

#pragma mark - Gesture Helpers

- (void)cancelAllGestures {
    [super cancelAllGestures];
    [scissor cancelAllTouches];
    [[MMDrawingTouchGestureRecognizer sharedInstance] cancel];
}

/**
 * returns the value in radians that the sidebar buttons
 * should be rotated to stay pointed "down"
 */
- (CGFloat)sidebarButtonRotation {
    CGFloat rotationValue = -([[[MMRotationManager sharedInstance] currentRotationReading] angle] + M_PI / 2);
    if (isnan(rotationValue)) {
        [[[Mixpanel sharedInstance] people] set:kMPFailedRotationReading to:@(YES)];
        rotationValue = 0;
    }
    return rotationValue;
}

- (Tool*)activePen {
    if (scissorButton.selected) {
        return scissor;
    } else if (eraserButton.selected) {
        return eraser;
    } else if (pencilTool.pencilButton.selected) {
        return pen;
    } else if (pencilTool.highlighterButton.selected) {
        return highlighter;
    } else {
        return marker;
    }
}

#pragma mark - MMPencilAndPaletteViewDelegate

- (void)highlighterTapped:(UIButton*)button {
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = YES;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
    [[NSUserDefaults standardUserDefaults] setObject:kBrushHighlighter forKey:kSelectedBrush];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)pencilTapped:(UIButton*)_button {
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = YES;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
    [[NSUserDefaults standardUserDefaults] setObject:kBrushPencil forKey:kSelectedBrush];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)markerTapped:(UIButton*)_button {
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = YES;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
    [[NSUserDefaults standardUserDefaults] setObject:kBrushMarker forKey:kSelectedBrush];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)colorMenuToggled {
    // noop
}

- (void)didChangeColorTo:(UIColor*)color {
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    highlighter.color = color;
    pen.color = color;
    marker.color = color;
    if (!pencilTool.selected) {
        [self markerTapped:nil];
    }
}

#pragma mark - Tool Button Actions

- (void)undo:(UIButton*)_button {
    if (![self isActivelyGesturing]) {
        // only allow undo/redo when no other gestures
        // are active
        MMUndoablePaperView* obj = [visibleStackHolder peekSubview];
        [obj.undoRedoManager undo];
        [obj saveToDisk:nil];
    }
}

- (void)redo:(UIButton*)_button {
    if (![self isActivelyGesturing]) {
        // only allow undo/redo when no other gestures
        // are active
        MMUndoablePaperView* obj = [visibleStackHolder peekSubview];
        [obj.undoRedoManager redo];
        [obj saveToDisk:nil];
    }
}

- (void)eraserTapped:(UIButton*)_button {
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = YES;
    pencilTool.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

- (void)scissorTapped:(UIButton*)_button {
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = YES;
}


- (void)handTapped:(UIButton*)_button {
    [[visibleStackHolder peekSubview] cancelAllGestures];
    handButton.selected = YES;
    rulerButton.selected = NO;
}

- (void)bounceSidebarButton:(MMSidebarButton*)button {
    CheckMainThread;
    CGPoint onscreen = button.center;

    [UIView animateKeyframesWithDuration:.7 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.25 animations:^{
            button.center = CGPointMake(onscreen.x + 12, onscreen.y);
        }];
        [UIView addKeyframeWithRelativeStartTime:.25 relativeDuration:.3 animations:^{
            button.center = onscreen;
        }];
        [UIView addKeyframeWithRelativeStartTime:.55 relativeDuration:.25 animations:^{
            button.center = CGPointMake(onscreen.x + 8, onscreen.y);
        }];
        [UIView addKeyframeWithRelativeStartTime:.80 relativeDuration:.2 animations:^{
            button.center = onscreen;
        }];
    } completion:nil];
}

- (void)rulerTapped:(UIButton*)_button {
    if (!rulerButton.selected) {
        numberOfRulerGesturesWithoutStroke = 0;
    }
    [[visibleStackHolder peekSubview] cancelAllGestures];
    handButton.selected = NO;
    rulerButton.selected = YES;
}


#pragma mark - Page/Save Button Actions

/**
 * adds a new blank page to the visible stack
 * without changing the hidden stack's contents
 */
- (void)addPageButtonTapped:(UIButton*)_button {
    [super addPageButtonTapped:_button];

    MMEditablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:hiddenStackHolder.bounds];
    page.delegate = self;
    [hiddenStackHolder pushSubview:page];
    [[visibleStackHolder peekSubview] enableAllGestures];
    [self popTopPageOfHiddenStack];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
    [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedPage: @(YES) }];
}

- (void)tempButtonTapped:(UIButton*)_button {
    DebugLog(@"temp button");
}

- (BOOL)buttonsVisible {
    return pencilTool.alpha;
}

- (void)setButtonsVisible:(BOOL)visible animated:(BOOL)animated {
    [self setButtonsVisible:visible withDuration:animated ? 0.3 : 0];
}

- (void)setButtonsVisible:(BOOL)visible withDuration:(CGFloat)duration {
    void (^block)() = ^{
        [self.toolbar setButtonsVisible:visible];
        settingsButton.alpha = visible;
        pencilTool.alpha = visible;
    };

    if (duration > 0) {
        [UIView animateWithDuration:duration animations:block];
    } else {
        block();
    }
}

#pragma mark - MMRotationManagerDelegate

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading {
    [NSThread performBlockOnMainThread:^{
        CGFloat rotationValue = [self sidebarButtonRotation];
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotationValue);
        addPageSidebarButton.transform = rotationTransform;
        insertImageButton.transform = rotationTransform;
        scissorButton.transform = rotationTransform;
        pencilTool.transform = rotationTransform;
        eraserButton.transform = rotationTransform;
        shareButton.transform = rotationTransform;
        undoButton.transform = rotationTransform;
        redoButton.transform = rotationTransform;
        rulerButton.transform = rotationTransform;
        handButton.transform = rotationTransform;
        settingsButton.transform = rotationTransform;

        addPageSidebarButton.rotation = rotationValue;
        insertImageButton.rotation = rotationValue;
        scissorButton.rotation = rotationValue;
        pencilTool.rotation = rotationValue;
        eraserButton.rotation = rotationValue;
        shareButton.rotation = rotationValue;
        undoButton.rotation = rotationValue;
        redoButton.rotation = rotationValue;
        rulerButton.rotation = rotationValue;
        handButton.rotation = rotationValue;
        settingsButton.rotation = rotationValue;
    }];
}

- (void)didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel {
    [NSThread performBlockOnMainThread:^{
        [[visibleStackHolder peekSubview] didUpdateAccelerometerWithRawReading:currentRawReading];
    }];
}

- (void)willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient {
    // noop
}

- (void)didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient {
    // noop
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    // noop
}


#pragma mark - Bezel Left and Right Gestures

- (void)isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture {
    // see comments in [MMPaperStackView:isBezelingInRightWithGesture] for
    // comments on the messy `hasSeenSubstateBegin`
    if (!bezelGesture.hasSeenSubstateBegin && (bezelGesture.subState == UIGestureRecognizerStateBegan ||
                                               bezelGesture.subState == UIGestureRecognizerStateChanged)) {
        // cancel any strokes that this gesture is using
        for (UITouch* touch in bezelGesture.touches) {
            [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
            [scissor cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInLeftWithGesture:bezelGesture];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

- (void)isBezelingInRightWithGesture:(MMBezelInGestureRecognizer*)bezelGesture {
    // see comments in [MMPaperStackView:isBezelingInRightWithGesture] for
    // comments on the messy `hasSeenSubstateBegin`
    if (!bezelGesture.hasSeenSubstateBegin && (bezelGesture.subState == UIGestureRecognizerStateBegan ||
                                               bezelGesture.subState == UIGestureRecognizerStateChanged)) {
        // cancel any strokes that this gesture is using
        for (UITouch* touch in bezelGesture.touches) {
            [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
            [scissor cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInRightWithGesture:bezelGesture];
    [[bezelStackHolder peekSubview] updateThumbnailVisibility];
}

#pragma mark - MMPaperViewDelegate

- (CGRect)isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches {
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for (UITouch* touch in touches) {
        [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }

    return [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
}

- (void)didDrawStrokeOfCm:(CGFloat)distanceInCentimeters {
    @autoreleasepool {
        if ([self activePen] == pen) {
            [[[Mixpanel sharedInstance] people] increment:kMPDistanceDrawn by:@(distanceInCentimeters / 100.0)];
        } else if ([self activePen] == eraser) {
            [[[Mixpanel sharedInstance] people] increment:kMPDistanceErased by:@(distanceInCentimeters / 100.0)];
        }
    }
}

#pragma mark = List View

- (void)immediatelyTransitionToListView {
    [super immediatelyTransitionToListView];
    [self setButtonsVisible:NO animated:NO];
}

- (void)isBeginningToScaleReallySmall:(MMPaperView*)page {
    // make sure the currently edited page is being saved
    // to disk if need be
    if ([page isKindOfClass:[MMEditablePaperView class]]) {
        __block MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        [pageToSave setEditable:NO];
        //        DebugLog(@"page %@ isn't editable", pageToSave.uuid);
        [[visibleStackHolder peekSubview] saveToDisk:nil];
    } else {
        DebugLog(@"would save, but can't b/c its readonly page");
    }
    // update UI for scaling small into list view
    [self setButtonsVisible:NO animated:YES];
    [scissor cancelAllTouches];
    [super isBeginningToScaleReallySmall:page];
    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
}
- (void)finishedScalingReallySmall:(MMPaperView*)page animated:(BOOL)animated {
    [super finishedScalingReallySmall:page animated:animated];
    [self saveStacksToDisk];
    [rulerView setHidden:YES];
}
- (void)cancelledScalingReallySmall:(MMPaperView*)page {
    [self setButtonsVisible:YES animated:YES];
    [super cancelledScalingReallySmall:page];

    // ok, we've zoomed into this page now
    if ([page isKindOfClass:[MMEditablePaperView class]]) {
        MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        if (pageToSave.drawableView) {
            // only re-allow editing if it still has the editable view
            [pageToSave setEditable:YES];
        }
        [pageToSave updateThumbnailVisibility];
        //        DebugLog(@"page %@ is editable", pageToSave.uuid);
    }
    [rulerView setHidden:NO];
}
- (void)finishedScalingBackToPageView:(MMPaperView*)page {
    [self setButtonsVisible:YES animated:YES];
    [super finishedScalingBackToPageView:page];
    [self saveStacksToDisk];
    [rulerView setHidden:NO];
    MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
    if (![editablePage hasEditsToSave]) {
        [editablePage setEditable:NO];
        [editablePage updateThumbnailVisibility];
    }
}

#pragma mark = Saving and Editing

- (void)didSavePage:(MMPaperView*)page {
    if (page.scale < kMinPageZoom) {
        if ([page isKindOfClass:[MMEditablePaperView class]]) {
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            if ([editablePage hasEditsToSave]) {
                //                DebugLog(@"page still has edits to save...");
            } else {
                //                DebugLog(@"page is done saving...");
                [(MMEditablePaperView*)page setEditable:NO];
                [(MMEditablePaperView*)page updateThumbnailVisibility];
                //                DebugLog(@"thumb for %@ is visible", page.uuid);
            }
        }
    } else {
        // we might be mid gesture here, so assuming that the
        // top page should actually be the top visible page isn't necessarily
        // true. instead, i should ask the PageCacheManager to recheck
        // if it can hand the currently top page the drawable view.
        if ([fromLeftBezelGesture isActivelyBezeling]) {
            [self didChangeTopPageTo:[bezelStackHolder peekSubview]];
        } else {
            [self didChangeTopPageTo:[visibleStackHolder peekSubview]];
        }
    }
}

- (BOOL)isPageEditable:(MMPaperView*)page {
    return page == [MMPageCacheManager sharedInstance].currentEditablePage;
}

#pragma mark = Ruler

/**
 * return YES if we're in hand mode, no otherwise
 */
- (BOOL)shouldAllowPan:(MMPaperView*)page {
    return handButton.selected;
}

- (void)didMoveRuler:(MMRulerToolGestureRecognizer*)gesture {
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for (UITouch* touch in gesture.validTouches) {
        [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }
    if (gesture.subState == UIGestureRecognizerStateBegan ||
        (gesture.state == UIGestureRecognizerStateBegan && gesture.subState == UIGestureRecognizerStateChanged)) {
        [self ownershipOfTouches:[NSSet setWithArray:gesture.validTouches] isGesture:gesture];
    }
    [rulerView updateLineAt:[gesture point1InView:rulerView] to:[gesture point2InView:rulerView]
           startingDistance:[gesture initialDistance]];
}

- (void)didStopRuler:(MMRulerToolGestureRecognizer*)gesture {
    if (rulerView.rulerIsVisible) {
        [rulerView liftRuler];
        numberOfRulerGesturesWithoutStroke++;

        if (numberOfRulerGesturesWithoutStroke > 2) {
            [self bounceSidebarButton:handButton];
        }
    }
}

#pragma mark - MMGestureTouchOwnershipDelegate

- (void)ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture {
    [super ownershipOfTouches:touches isGesture:gesture];
    if ([gesture isKindOfClass:[MMDrawingTouchGestureRecognizer class]] ||
        [gesture isKindOfClass:[MMBezelInGestureRecognizer class]]) {
        // only notify of our own gestures
        if ([fromLeftBezelGesture isActivelyBezeling] && [bezelStackHolder.subviews count]) {
            [[bezelStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
        } else {
            if ([fromLeftBezelGesture isActivelyBezeling]) {
                DebugLog(@"notifying of ownership during left bezel, but nothing in bezel holder");
            }
            [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
        }
    }
    [[MMDrawingTouchGestureRecognizer sharedInstance] ownershipOfTouches:touches isGesture:gesture];
}

- (NSArray*)scraps {
    @throw kAbstractMethodException;
}


#pragma mark - MMPageCacheManagerDelegate: Page Loading and Unloading

- (BOOL)isPageInVisibleStack:(MMPaperView*)page {
    return [visibleStackHolder containsSubview:page];
}

- (NSArray*)pagesInCurrentBezelGesture {
    return bezelStackHolder.subviews;
}

- (MMPaperView*)getPageBelow:(MMPaperView*)page {
    return [visibleStackHolder getPageBelow:page];
}

- (NSArray*)findPagesInVisibleRowsOfListView {
    CGPoint visibleScrollOffset;
    if (self.scrollEnabled) {
        visibleScrollOffset = self.contentOffset;
    } else {
        visibleScrollOffset = initialScrollOffsetFromTransitionToListView;
    }
    return [self findPagesInVisibleRowsOfListViewGivenOffset:visibleScrollOffset];
}

- (void)mayChangeTopPageTo:(MMPaperView*)page {
    [super mayChangeTopPageTo:page];
}

- (void)willChangeTopPageTo:(MMPaperView*)page {
    [super willChangeTopPageTo:page];
}

- (void)didChangeTopPageTo:(MMPaperView*)page {
    CheckMainThread;
    [super didChangeTopPageTo:(MMPaperView*)page];
}

- (void)willNotChangeTopPageTo:(MMPaperView*)page {
    [super willNotChangeTopPageTo:page];
}

#pragma mark - Stack Loading and Saving

- (void)saveStacksToDisk {
    [self.stackManager saveStacksToDisk];
}

- (void)buildDefaultContent {
    // just need to copy the visible/hiddenPages.plist files
    // and the content will be loaded from the bundle just fine

    NSURL* visiblePagesPlist = [[NSBundle mainBundle] URLForResource:@"visiblePages" withExtension:@"plist" subdirectory:@"Documents"];
    NSURL* hiddenPagesPlist = [[NSBundle mainBundle] URLForResource:@"hiddenPages" withExtension:@"plist" subdirectory:@"Documents"];

    [NSFileManager ensureDirectoryExistsAtPath:[[self.stackManager visiblePlistPath] stringByDeletingLastPathComponent]];

    [[NSFileManager defaultManager] copyItemAtPath:[visiblePagesPlist path]
                                            toPath:[self.stackManager visiblePlistPath]
                                             error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[hiddenPagesPlist path]
                                            toPath:[self.stackManager hiddenPlistPath]
                                             error:nil];
}

- (void)loadStacksFromDiskIntoListView:(BOOL)isListView {
    // check to see if we have any state to load at all, and if
    // not then build our default content
    if (![self.stackManager hasStateToLoad]) {
        // we don't have any pages, and we don't have any
        // state to load
        [self buildDefaultContent];
        [self loadStacksFromDiskIntoListView:isListView];
        return;
    } else {
        NSDictionary* pages = [self.stackManager loadFromDiskWithBounds:self.bounds];
        for (MMPaperView* page in [[pages objectForKey:@"visiblePages"] reverseObjectEnumerator]) {
            [self addPaperToBottomOfStack:page];
        }
        for (MMPaperView* page in [[pages objectForKey:@"hiddenPages"] reverseObjectEnumerator]) {
            [self addPaperToBottomOfHiddenStack:page];
        }
    }

    if ([self hasPages]) {
        // only load the image previews for the pages that will be visible
        // other page previews will load as the user turns the page,
        // or as they scroll the list view
        CGPoint scrollOffset = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
        NSArray* visiblePages = [self findPagesInVisibleRowsOfListViewGivenOffset:scrollOffset];
        for (MMEditablePaperView* page in visiblePages) {
            [page loadCachedPreview];
        }
        [self setButtonsVisible:YES animated:NO];

        // Open to list view if needed
        if (!isListView) {
            [[MMPageCacheManager sharedInstance] didChangeToTopPage:[[self visibleStackHolder] peekSubview]];
        } else {
            // open into list view if that was their last visible screen
            [self immediatelyTransitionToListView];
        }
    } else {
        // list is empty on purpose
        [self immediatelyTransitionToListView];
    }
}

- (BOOL)hasPages {
    return [visibleStackHolder.subviews count] > 0;
}

#pragma mark - JotViewDelegate

- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    // dont start a new stroke if one already exists
    if ([[[MMDrawingTouchGestureRecognizer sharedInstance] validTouches] count] > 0) {
        //        DebugLog(@"stroke already exists: %d", (int) [[[MMDrawingTouchGestureRecognizer sharedInstance] validTouches] count]);
        return NO;
    }
    if ([MMPageCacheManager sharedInstance].drawableView.state.currentStroke) {
        return NO;
    }
    for (MMScrapView* scrap in [[visibleStackHolder peekSubview] scrapsOnPaper]) {
        if (scrap.state.drawableView.state.currentStroke) {
            return NO;
        }
    }
    if (fromRightBezelGesture.subState == UIGestureRecognizerStateBegan ||
        fromRightBezelGesture.subState == UIGestureRecognizerStateChanged) {
        // don't allow new strokes during bezel
        return NO;
    }
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
    if ([rulerView rulerIsVisible]) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfRulerUses by:@(1)];
    }
    return [[self activePen] willBeginStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (void)willMoveStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [rulerView willMoveStrokeAt:[touch locationInView:rulerView]];
    [[self activePen] willMoveStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)shortStrokeEnding {
    [[self activePen] willEndStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch shortStrokeEnding:shortStrokeEnding];
}

- (void)didEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [[self activePen] didEndStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch];
    if ([self activePen] == pen) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPenUses by:@(1)];
    } else if ([self activePen] == eraser) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfEraserUses by:@(1)];
    }
}

- (void)willCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [[self activePen] willCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (void)didCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [[self activePen] didCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    return [[self activePen] colorForCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (JotBrushTexture*)textureForStroke {
    return [[self activePen] textureForStroke];
}

- (CGFloat)stepWidthForStroke {
    return [[self activePen] stepWidthForStroke];
}

- (BOOL)supportsRotation {
    return [[self activePen] supportsRotation];
}

- (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    //
    // we divide by scale so that when the user is zoomed in,
    // their pen is always writing at the same visible scale
    //
    // this lets them write smaller text / detail when zoomed in
    return [[self activePen] widthForCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (CGFloat)smoothnessForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    return [[self activePen] smoothnessForCoalescedTouch:coalescedTouch fromTouch:touch];
}

- (NSArray*)willAddElements:(NSArray*)elements toStroke:(JotStroke*)stroke fromPreviousElement:(AbstractBezierPathElement*)previousElement {
    MMRulerAdjustment* adjustments = [rulerView adjustElementsToStroke:[[self activePen] willAddElements:elements toStroke:stroke fromPreviousElement:previousElement] fromPreviousElement:previousElement];

    if (adjustments.didAdjust) {
        numberOfRulerGesturesWithoutStroke = 0;
    }

    return adjustments.elements;
}

#pragma mark - PolygonToolDelegate

- (void)beginShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool {
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView] andDidAdjust:NULL];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page beginScissorAtPoint:adjustedPoint];
}

- (void)continueShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool {
    BOOL didAdjust = NO;
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView] andDidAdjust:&didAdjust];
    if (didAdjust) {
        numberOfRulerGesturesWithoutStroke = 0;
    }
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    if (![page continueScissorAtPoint:adjustedPoint]) {
        [scissor cancelPolygonForTouch:touch];
    }
}

- (void)finishShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool {
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView] andDidAdjust:NULL];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page finishScissorAtPoint:adjustedPoint];
}

- (void)cancelShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool {
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView] andDidAdjust:NULL];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page cancelScissorAtPoint:adjustedPoint];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    [super scrollViewDidScroll:scrollView];
    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
}

#pragma mark - Gestures for List View

- (void)beginUITransitionFromPageView {
    [super beginUITransitionFromPageView];
    [[[MMPageCacheManager sharedInstance] currentEditablePage] cancelCurrentStrokeIfAny];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

- (void)beginUITransitionFromListView {
    [super beginUITransitionFromListView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
}

- (void)finishUITransitionToListView {
    [super finishUITransitionToListView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

- (void)finishUITransitionToPageView {
    [super finishUITransitionToPageView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:YES];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

- (void)disableAllGesturesForPageView {
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [super disableAllGesturesForPageView];
}

- (void)enableAllGesturesForPageView {
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:YES];
    [super enableAllGesturesForPageView];
}

#pragma mark - Sidebar Hit Test

- (BOOL)shouldPrioritizeSidebarButtonsForTaps {
    return self.isShowingPageView;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    if ([self shouldPrioritizeSidebarButtonsForTaps]) {
        UIView* view = [self.toolbar hitTest:point withEvent:event];
        if (view) {
            return view;
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - Check for Active Gestures

- (BOOL)isActivelyGesturing {
    return [super isActivelyGesturing] || [[MMDrawingTouchGestureRecognizer sharedInstance] isDrawing];
}

@end
