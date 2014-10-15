//
//  MMEditablePaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "UIView+SubviewStacks.h"
#import "MMRulerView.h"
#import "MMScrappedPaperView.h"
#import "MMScrapBubbleButton.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMMemoryProfileView.h"
#import "MMExportablePaperView.h"
#import "Mixpanel.h"
#import <mach/mach_time.h>  // for mach_absolute_time() and friends

struct SidebarButton{
    void* button;
    CGRect originalRect;
} SidebarButton;

@implementation MMEditablePaperStackView{
    UIPopoverController* jotTouchPopover;
    MMMemoryProfileView* memoryView;
    struct SidebarButton buttons[10];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [[NSFileManager defaultManager] preCacheDirectoryListingAt:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Pages"]];
        
        [MMPageCacheManager sharedInstance].delegate = self;

        self.delegate = self;
        
        stackManager = [[MMStackManager alloc] initWithVisibleStack:visibleStackHolder andHiddenStack:hiddenStackHolder andBezelStack:bezelStackHolder];
        
        [MMPageCacheManager sharedInstance].drawableView = [[JotView alloc] initWithFrame:self.bounds];
//        [MMPageCacheManager sharedInstance].drawableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.3];
        [[JotStylusManager sharedInstance] setPalmRejectorDelegate:[MMPageCacheManager sharedInstance].drawableView];

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
        addPageSidebarButton = [[MMPlusButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        addPageSidebarButton.delegate = self;
        [addPageSidebarButton addTarget:self action:@selector(addPageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addPageSidebarButton];
        buttons[0].button = (__bridge void *)(addPageSidebarButton);
        buttons[0].originalRect = addPageSidebarButton.frame;
        
        shareButton = [[MMShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        shareButton.delegate = self;
        [self addSubview:shareButton];
        buttons[1].button = (__bridge void *)(shareButton);
        buttons[1].originalRect = shareButton.frame;
        
//        settingsButton = [[MMAdonitButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        settingsButton.delegate = self;
//        [settingsButton addTarget:self action:@selector(jotSettingsTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:settingsButton];
        
        // memory button
        CGRect settingsButtonRect = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 2 * 60, kWidthOfSidebarButton, kWidthOfSidebarButton);
        settingsButton = [[MMTextButton alloc] initWithFrame:settingsButtonRect andFont:[UIFont systemFontOfSize:20] andLetter:@"!?" andXOffset:2 andYOffset:0];
        settingsButton.delegate = self;
        [settingsButton addTarget:self action:@selector(toggleMemoryView:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:settingsButton];
        
        
        pencilTool = [[MMPencilAndPaletteView alloc] initWithButtonFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar, kWidthOfSidebarButton, kWidthOfSidebarButton) andScreenSize:self.bounds.size];
        pencilTool.delegate = self;
        [self addSubview:pencilTool];
        buttons[2].button = (__bridge void *)(pencilTool.pencilButton);
        buttons[2].originalRect = [pencilTool convertRect:pencilTool.pencilButton.frame toView:self];
        
        eraserButton = [[MMPencilEraserButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        eraserButton.delegate = self;
        [eraserButton addTarget:self action:@selector(eraserTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:eraserButton];
        buttons[3].button = (__bridge void *)(eraserButton);
        buttons[3].originalRect = eraserButton.frame;
        
        CGRect scissorButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton);
        scissorButton = [[MMScissorButton alloc] initWithFrame:scissorButtonFrame];
        scissorButton.delegate = self;
        [scissorButton addTarget:self action:@selector(scissorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:scissorButton];
        buttons[4].button = (__bridge void *)(scissorButton);
        buttons[4].originalRect = scissorButton.frame;

        insertImageButton = [[MMImageButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        insertImageButton.delegate = self;
        [self addSubview:insertImageButton];
        buttons[5].button = (__bridge void *)(insertImageButton);
        buttons[5].originalRect = insertImageButton.frame;

        
        
        
        CGRect handButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 5.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        handButton = [[MMHandButton alloc] initWithFrame:handButtonFrame];
        handButton.delegate = self;
        [handButton addTarget:self action:@selector(handTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:handButton];
        buttons[6].button = (__bridge void *)(handButton);
        buttons[6].originalRect = handButton.frame;

        CGRect rulerButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 6.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        rulerButton = [[MMRulerButton alloc] initWithFrame:rulerButtonFrame];
        rulerButton.delegate = self;
        [rulerButton addTarget:self action:@selector(rulerTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rulerButton];
        buttons[7].button = (__bridge void *)(rulerButton);
        buttons[7].originalRect = rulerButton.frame;

        
        
        
        
        
        undoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2 - 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        undoButton.delegate = self;
        [undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        undoButton.reverseArrow = YES;
        [self addSubview:undoButton];
        buttons[8].button = (__bridge void *)(undoButton);
        buttons[8].originalRect = CGRectInset(undoButton.frame, -(kWidthOfSidebar - kWidthOfSidebarButton)/2, 0) ;

        redoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        redoButton.delegate = self;
        [redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
        buttons[9].button = (__bridge void *)(redoButton);
        buttons[9].originalRect = CGRectInset(redoButton.frame, -(kWidthOfSidebar - kWidthOfSidebarButton)/2, 0) ;
        buttons[9].originalRect.size.height += (kWidthOfSidebar - kWidthOfSidebarButton)/2;

        
        //
        // accelerometer for rotating buttons
        // ================================================================================
        
        [[MMRotationManager sharedInstance] setDelegate:self];
        
        
        
        
        // unused buttons
        
        //    CGRect textButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        //    textButton = [[MMTextButton alloc] initWithFrame:textButtonFrame andFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:28] andLetter:@"T" andXOffset:2 andYOffset:0];
        //    textButton.delegate = self;
        //    [textButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //    [self addSubview:textButton];
        
        //    polylineButton = [[MMPolylineButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 6, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        //    polylineButton.delegate = self;
        //    [polylineButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //    [self addSubview:polylineButton];
        
        //     documentBackgroundSidebarButton = [[MMPaperButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 7, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        //     documentBackgroundSidebarButton.delegate = self;
        //     documentBackgroundSidebarButton.enabled = NO;
        //     [documentBackgroundSidebarButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //     [self addSubview:documentBackgroundSidebarButton];
        
        //    mapButton = [[MMMapButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 8, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        //    mapButton.delegate = self;
        //    [mapButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //    [self addSubview:mapButton];

        
        
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.multipleTouchEnabled = YES;
        self.bounces = YES;
        self.alwaysBounceHorizontal = NO;
        self.canCancelContentTouches = YES;
        self.opaque = YES;
        self.clearsContextBeforeDrawing = YES;
        self.clipsToBounds = YES;
        self.delaysContentTouches = NO;
        
        
        pencilTool.selected = YES;
        handButton.selected = YES;
        
        [NSThread performBlockInBackground:^{
            @autoreleasepool {
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector:@selector(connectionChange:)
                                                             name:JotStylusManagerDidChangeConnectionStatus
                                                           object:nil];
                [[JotStylusManager sharedInstance] setRejectMode:NO];
            }
        }];
        
        
        rulerView = [[MMRulerView alloc] initWithFrame:self.bounds];
        [self addSubview:rulerView];
        
        
        [self addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];
        
        [[MMDrawingTouchGestureRecognizer sharedInstance] setTouchDelegate:self];
        [self addGestureRecognizer:[MMDrawingTouchGestureRecognizer sharedInstance]];
        
    }
    return self;
}

-(void) setMemoryView:(MMMemoryProfileView*)_memoryView{
    memoryView = _memoryView;
}


-(void) toggleMemoryView:(UIButton*)button{
    memoryView.hidden = !memoryView.hidden;
}

-(int) fullByteSize{
    return [super fullByteSize] + addPageSidebarButton.fullByteSize + shareButton.fullByteSize + settingsButton.fullByteSize + pencilTool.fullByteSize + eraserButton.fullByteSize + scissorButton.fullByteSize + insertImageButton.fullByteSize + handButton.fullByteSize + rulerButton.fullByteSize + undoButton.fullByteSize + redoButton.fullByteSize + rulerView.fullByteSize;
}

#pragma mark - Gesture Helpers

-(void) cancelAllGestures{
    [super cancelAllGestures];
    [scissor cancelAllTouches];
    [[MMDrawingTouchGestureRecognizer sharedInstance] cancel];
}

/**
 * returns the value in radians that the sidebar buttons
 * should be rotated to stay pointed "down"
 */
-(CGFloat) sidebarButtonRotation{
    return -([[[MMRotationManager sharedInstance] currentRotationReading] angle] + M_PI/2);
}

-(Tool*) activePen{
    if(scissorButton.selected){
        return scissor;
    }else if(eraserButton.selected){
        return eraser;
    }else{
        return pen;
    }
}

#pragma mark - MMPencilAndPaletteViewDelegate

-(void) penTapped:(UIButton*)_button{
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = YES;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

-(void) colorMenuToggled{
    // noop
}

-(void) didChangeColorTo:(UIColor*)color{
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    pen.color = color;
    if(!pencilTool.selected){
        [self penTapped:nil];
    }
}

#pragma mark - Tool Button Actions

-(void) undo:(UIButton*)_button{
    if(![self isActivelyGesturing]){
        // only allow undo/redo when no other gestures
        // are active
        MMUndoablePaperView* obj = [visibleStackHolder peekSubview];
        [obj.undoRedoManager undo];
        [obj saveToDisk:nil];
    }
}

-(void) redo:(UIButton*)_button{
    if(![self isActivelyGesturing]){
        // only allow undo/redo when no other gestures
        // are active
        MMUndoablePaperView* obj = [visibleStackHolder peekSubview];
        [obj.undoRedoManager redo];
        [obj saveToDisk:nil];
    }
}

-(void) eraserTapped:(UIButton*)_button{
    [scissor cancelAllTouches];
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = YES;
    pencilTool.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

-(void) scissorTapped:(UIButton*)_button{
    [[JotStrokeManager sharedInstance] cancelAllStrokes];
    eraserButton.selected = NO;
    pencilTool.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = YES;
}


-(void) handTapped:(UIButton*)_button{
    [[visibleStackHolder peekSubview] cancelAllGestures];
    handButton.selected = YES;
    rulerButton.selected = NO;
}

-(void) rulerTapped:(UIButton*)_button{
    [[visibleStackHolder peekSubview] cancelAllGestures];
    handButton.selected = NO;
    rulerButton.selected = YES;
}

-(void) jotSettingsTapped:(UIButton*)_button{
//    if(jotTouchPopover && jotTouchPopover.popoverVisible){
//        return;
//    }else if(jotTouchPopover){
//        [jotTouchPopover dismissPopoverAnimated:NO];
//    }
//    JotSettingsViewController* settings = [[JotSettingsViewController alloc] initWithOnOffSwitch: YES];
//    jotTouchPopover = [[UIPopoverController alloc] initWithContentViewController:settings];
//    [jotTouchPopover presentPopoverFromRect:_button.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
//    [jotTouchPopover setPopoverContentSize:CGSizeMake(300, 446) animated:NO];
}


#pragma mark - Page/Save Button Actions

/**
 * adds a new blank page to the visible stack
 * without changing the hidden stack's contents
 */
-(void) addPageButtonTapped:(UIButton*)_button{
    [super addPageButtonTapped:_button];
    
    MMEditablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:hiddenStackHolder.bounds];
    page.isBrandNewPage = YES;
    page.delegate = self;
    [hiddenStackHolder pushSubview:page];
    [[visibleStackHolder peekSubview] enableAllGestures];
    [self popTopPageOfHiddenStack];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
    [[[Mixpanel sharedInstance] people] set:@{kMPHasAddedPage : @(YES)}];
}

-(void) tempButtonTapped:(UIButton*)_button{
    debug_NSLog(@"temp button");
}

-(void) setButtonsVisible:(BOOL)visible{
    [self setButtonsVisible:visible withDuration:0.3];
}

-(void) setButtonsVisible:(BOOL)visible withDuration:(CGFloat)duration{
    [UIView animateWithDuration:duration animations:^{
        addPageSidebarButton.alpha = visible;
        documentBackgroundSidebarButton.alpha = visible;
        polylineButton.alpha = visible;
        insertImageButton.alpha = visible;
        textButton.alpha = visible;
        pencilTool.alpha = visible;
        scissorButton.alpha = visible;
        eraserButton.alpha = visible;
        shareButton.alpha = visible;
        mapButton.alpha = visible;
        redoButton.alpha = visible;
        undoButton.alpha = visible;
        rulerButton.alpha = visible;
        handButton.alpha = visible;
        settingsButton.alpha = visible;
    }];
}

#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithReading:(MMVector*)currentRawReading{
    [NSThread performBlockOnMainThread:^{
        CGFloat rotationValue = [self sidebarButtonRotation];
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotationValue);
        addPageSidebarButton.transform = rotationTransform;
        documentBackgroundSidebarButton.transform = rotationTransform;
        polylineButton.transform = rotationTransform;
        insertImageButton.transform = rotationTransform;
        textButton.transform = rotationTransform;
        scissorButton.transform = rotationTransform;
        pencilTool.transform = rotationTransform;
        eraserButton.transform = rotationTransform;
        shareButton.transform = rotationTransform;
        mapButton.transform = rotationTransform;
        undoButton.transform = rotationTransform;
        redoButton.transform = rotationTransform;
        rulerButton.transform = rotationTransform;
        handButton.transform = rotationTransform;
        settingsButton.transform = rotationTransform;
        
        addPageSidebarButton.rotation = rotationValue;
        documentBackgroundSidebarButton.rotation = rotationValue;
        polylineButton.rotation = rotationValue;
        insertImageButton.rotation = rotationValue;
        textButton.rotation = rotationValue;
        scissorButton.rotation = rotationValue;
        pencilTool.rotation = rotationValue;
        eraserButton.rotation = rotationValue;
        shareButton.rotation = rotationValue;
        mapButton.rotation = rotationValue;
        undoButton.rotation = rotationValue;
        redoButton.rotation = rotationValue;
        rulerButton.rotation = rotationValue;
        handButton.rotation = rotationValue;
        settingsButton.rotation = rotationValue;
    }];
}

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    [NSThread performBlockOnMainThread:^{
        [[visibleStackHolder peekSubview] didUpdateAccelerometerWithRawReading:currentRawReading];
    }];
}

-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    // noop
}

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    // noop
}

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)orientation{
    // noop
}


#pragma mark - Bezel Left and Right Gestures

-(void) isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture{
    // see comments in [MMPaperStackView:isBezelingInRightWithGesture] for
    // comments on the messy `hasSeenSubstateBegin`
    if(!bezelGesture.hasSeenSubstateBegin && (bezelGesture.subState == UIGestureRecognizerStateBegan ||
                                              bezelGesture.subState == UIGestureRecognizerStateChanged)){
        // cancel any strokes that this gesture is using
        for(UITouch* touch in bezelGesture.touches){
            [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
            [scissor cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInLeftWithGesture:bezelGesture];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

-(void) isBezelingInRightWithGesture:(MMBezelInGestureRecognizer *)bezelGesture{
    // see comments in [MMPaperStackView:isBezelingInRightWithGesture] for
    // comments on the messy `hasSeenSubstateBegin`
    if(!bezelGesture.hasSeenSubstateBegin && (bezelGesture.subState == UIGestureRecognizerStateBegan ||
                                              bezelGesture.subState == UIGestureRecognizerStateChanged)){
        // cancel any strokes that this gesture is using
        for(UITouch* touch in bezelGesture.touches){
            [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
            [scissor cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInRightWithGesture:bezelGesture];
    [[bezelStackHolder peekSubview] updateThumbnailVisibility];
}

#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for(UITouch* touch in touches){
        [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }
    
    return [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
}

-(void) didDrawStrokeOfCm:(CGFloat)distanceInCentimeters{
    @autoreleasepool {
        if([self activePen] == pen){
            [[[Mixpanel sharedInstance] people] increment:kMPDistanceDrawn by:@(distanceInCentimeters / 100.0)];
        }else if([self activePen] == eraser){
            [[[Mixpanel sharedInstance] people] increment:kMPDistanceErased by:@(distanceInCentimeters / 100.0)];
        }
    }
}

#pragma mark = List View

-(void) isBeginningToScaleReallySmall:(MMPaperView *)page{
    // make sure the currently edited page is being saved
    // to disk if need be
    if([page isKindOfClass:[MMEditablePaperView class]]){
        __block MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        [pageToSave setEditable:NO];
//        debug_NSLog(@"page %@ isn't editable", pageToSave.uuid);
        [[visibleStackHolder peekSubview] saveToDisk:nil];
    }else{
        debug_NSLog(@"would save, but can't b/c its readonly page");
    }
    // update UI for scaling small into list view
    [self setButtonsVisible:NO];
    [scissor cancelAllTouches];
    [super isBeginningToScaleReallySmall:page];
    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
}
-(void) finishedScalingReallySmall:(MMPaperView *)page{
    [super finishedScalingReallySmall:page];
    [self saveStacksToDisk];
//    [TestFlight passCheckpoint:@"NAV_TO_LIST_FROM_PAGE"];
    [rulerView setHidden:YES];
}
-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    [self setButtonsVisible:YES];
    [super cancelledScalingReallySmall:page];

    // ok, we've zoomed into this page now
    if([page isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        [pageToSave setEditable:YES];
        [pageToSave updateThumbnailVisibility];
//        debug_NSLog(@"page %@ is editable", pageToSave.uuid);
    }
    [rulerView setHidden:NO];
}
-(void) finishedScalingBackToPageView:(MMPaperView*)page{
    [self setButtonsVisible:YES];
    [super finishedScalingBackToPageView:page];
    [self saveStacksToDisk];
    [rulerView setHidden:NO];
    MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
    if(![editablePage hasEditsToSave]){
        [editablePage setEditable:NO];
        [editablePage updateThumbnailVisibility];
    }
//    [TestFlight passCheckpoint:@"NAV_TO_PAGE_FROM_LIST"];
}

#pragma mark = Saving and Editing

-(void) didSavePage:(MMPaperView*)page{
    if(page.scale < kMinPageZoom){
        if([page isKindOfClass:[MMEditablePaperView class]]){
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            if([editablePage hasEditsToSave]){
//                debug_NSLog(@"page still has edits to save...");
            }else{
//                debug_NSLog(@"page is done saving...");
                [(MMEditablePaperView*)page setEditable:NO];
                [(MMEditablePaperView*)page updateThumbnailVisibility];
//                debug_NSLog(@"thumb for %@ is visible", page.uuid);
            }
        }
    }else{
        // we might be mid gesture here, so assuming that the
        // top page should actually be the top visible page isn't necessarily
        // true. instead, i should ask the PageCacheManager to recheck
        // if it can hand the currently top page the drawable view.
        if([fromLeftBezelGesture isActivelyBezeling]){
            [self didChangeTopPageTo:[bezelStackHolder peekSubview]];
        }else{
            [self didChangeTopPageTo:[visibleStackHolder peekSubview]];
        }
    }
}

-(BOOL) isPageEditable:(MMPaperView*)page{
    return page == [MMPageCacheManager sharedInstance].currentEditablePage;
}

#pragma mark = Ruler

/**
 * return YES if we're in hand mode, no otherwise
 */
-(BOOL) shouldAllowPan:(MMPaperView*)page{
    return handButton.selected;
}

-(void) didMoveRuler:(MMRulerToolGestureRecognizer *)gesture{
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for(UITouch* touch in gesture.validTouches){
        [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }
    if(gesture.subState == UIGestureRecognizerStateBegan ||
       (gesture.state == UIGestureRecognizerStateBegan && gesture.subState == UIGestureRecognizerStateChanged)){
           [self ownershipOfTouches:[NSSet setWithArray:gesture.validTouches] isGesture:gesture];
    }
    [rulerView updateLineAt:[gesture point1InView:rulerView] to:[gesture point2InView:rulerView]
           startingDistance:[gesture initialDistance]];
}

-(void) didStopRuler:(MMRulerToolGestureRecognizer *)gesture{
    [rulerView liftRuler];
}

#pragma mark - MMGestureTouchOwnershipDelegate

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [super ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMDrawingTouchGestureRecognizer class]] ||
       [gesture isKindOfClass:[MMBezelInGestureRecognizer class]]){
        // only notify of our own gestures
        if([fromLeftBezelGesture isActivelyBezeling] && [bezelStackHolder.subviews count]){
            [[bezelStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
        }else{
            if([fromLeftBezelGesture isActivelyBezeling]){
                NSLog(@"notifying of ownership during left bezel, but nothing in bezel holder");
            }
            [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
        }
    }
    [[MMDrawingTouchGestureRecognizer sharedInstance] ownershipOfTouches:touches isGesture:gesture];
}

-(NSArray*) scraps{
    @throw kAbstractMethodException;
}


#pragma mark - MMPageCacheManagerDelegate: Page Loading and Unloading

-(BOOL) isPageInVisibleStack:(MMPaperView*)page{
    return [visibleStackHolder containsSubview:page];
}

-(NSArray*) pagesInCurrentBezelGesture{
    return bezelStackHolder.subviews;
}

-(MMPaperView*) getPageBelow:(MMPaperView*)page{
    return [visibleStackHolder getPageBelow:page];
}

-(NSArray*) findPagesInVisibleRowsOfListView{
    CGPoint visibleScrollOffset;
    if(self.scrollEnabled){
        visibleScrollOffset = self.contentOffset;
    }else{
        visibleScrollOffset = initialScrollOffsetFromTransitionToListView;
    }
    return [self findPagesInVisibleRowsOfListViewGivenOffset:visibleScrollOffset];
}

-(void) mayChangeTopPageTo:(MMPaperView*)page{
    [super mayChangeTopPageTo:page];
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    [super willChangeTopPageTo:page];
}

-(void) didChangeTopPageTo:(MMPaperView*)page{
    CheckMainThread;
    [super didChangeTopPageTo:(MMPaperView*)page];
}

-(void) willNotChangeTopPageTo:(MMPaperView*)page{
    [super willNotChangeTopPageTo:page];
}

#pragma mark - Stack Loading and Saving

-(void) saveStacksToDisk{
    [stackManager saveStacksToDisk];
}

-(void) buildDefaultContent{
    
    // just need to copy the visible/hiddenPages.plist files
    // and the content will be loaded from the bundle just fine
    
    NSString* documentsPath = [NSFileManager documentsPath];
    NSURL* realDocumentsPath = [NSURL URLWithString:[documentsPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSURL* visiblePagesPlist = [[NSBundle mainBundle] URLForResource:@"visiblePages" withExtension:@"plist" subdirectory:@"Documents"];
    NSURL* hiddenPagesPlist = [[NSBundle mainBundle] URLForResource:@"hiddenPages" withExtension:@"plist" subdirectory:@"Documents"];
    
    [[NSFileManager defaultManager] copyItemAtPath:[visiblePagesPlist path]
                                            toPath:[[realDocumentsPath path] stringByAppendingPathComponent:@"visiblePages.plist"]
                                                    error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[hiddenPagesPlist path]
                                            toPath:[[realDocumentsPath path] stringByAppendingPathComponent:@"hiddenPages.plist"]
                                             error:nil];
}

-(void) finishedLoading{
    @throw  kAbstractMethodException;
}

-(void) loadStacksFromDisk{

    // check to see if we have any state to load at all, and if
    // not then build our default content
    if(![stackManager hasStateToLoad]){
        // we don't have any pages, and we don't have any
        // state to load
        self.userInteractionEnabled = NO;
        UIView* white = [[UIView alloc] initWithFrame:self.bounds];
        white.backgroundColor = [UIColor whiteColor];
        [self insertSubview:white belowSubview:visibleStackHolder];
        [NSThread performBlockInBackground:^{
            [self buildDefaultContent];
            [NSThread performBlockOnMainThread:^{
                self.userInteractionEnabled = YES;
                [white removeFromSuperview];
                [self loadStacksFromDisk];
            }];
        }];
        return;
    }else{
        NSDictionary* pages = [stackManager loadFromDiskWithBounds:self.bounds];
        for(MMPaperView* page in [[pages objectForKey:@"visiblePages"] reverseObjectEnumerator]){
            [self addPaperToBottomOfStack:page];
        }
        for(MMPaperView* page in [[pages objectForKey:@"hiddenPages"] reverseObjectEnumerator]){
            [self addPaperToBottomOfHiddenStack:page];
        }
    }
    
    
    
    if([self hasPages]){
        // load the state for the top page in the visible stack
        [[visibleStackHolder peekSubview] loadStateAsynchronously:NO
                                                         withSize:[MMPageCacheManager sharedInstance].drawableView.pagePtSize
                                                         andScale:[MMPageCacheManager sharedInstance].drawableView.scale
                                                       andContext:[[MMPageCacheManager sharedInstance].drawableView context]];
        
        
        // only load the image previews for the pages that will be visible
        // other page previews will load as the user turns the page,
        // or as they scroll the list view
        CGPoint scrollOffset = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
        NSArray* visiblePages = [self findPagesInVisibleRowsOfListViewGivenOffset:scrollOffset];
        for(MMEditablePaperView* page in visiblePages){
            [page loadCachedPreview];
        }
        
        [self willChangeTopPageTo:[visibleStackHolder peekSubview]];
        [self didChangeTopPage];
        [self finishedLoading];
    }else{
        // list is empty on purpose
        [self immediatelyTransitionToListView];
    }
    

}

-(BOOL) hasPages{
    return [visibleStackHolder.subviews count] > 0;
}

#pragma mark - JotViewDelegate

-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    // dont start a new stroke if one already exists
    if([[[MMDrawingTouchGestureRecognizer sharedInstance] validTouches] count] > 0){
//        debug_NSLog(@"stroke already exists: %d", (int) [[[MMDrawingTouchGestureRecognizer sharedInstance] validTouches] count]);
        return NO;
    }
    if([MMPageCacheManager sharedInstance].drawableView.state.currentStroke){
        return NO;
    }
    for(MMScrapView* scrap in [[visibleStackHolder peekSubview] scrapsOnPaper]){
        if(scrap.state.drawableView.state.currentStroke){
            return NO;
        }
    }
    if(fromRightBezelGesture.subState == UIGestureRecognizerStateBegan ||
       fromRightBezelGesture.subState == UIGestureRecognizerStateChanged){
        // don't allow new strokes during bezel
        return NO;
    }
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
    if([rulerView rulerIsVisible]){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfRulerUses by:@(1)];
    }
    return [[self activePen] willBeginStrokeWithTouch:touch];
}

-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    [rulerView willMoveStrokeAt:[touch locationInView:rulerView]];
    [[self activePen] willMoveStrokeWithTouch:touch];
}

-(void) willEndStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] willEndStrokeWithTouch:touch];
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] didEndStrokeWithTouch:touch];
    if([self activePen] == pen){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPenUses by:@(1)];
    }else if([self activePen] == eraser){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfEraserUses by:@(1)];
    }
}

-(void) willCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    [[self activePen] willCancelStroke:stroke withTouch:touch];
}

-(void) didCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    [[self activePen] didCancelStroke:stroke withTouch:touch];
}

-(UIColor*) colorForTouch:(JotTouch *)touch{
    return [[self activePen] colorForTouch:touch];
}

-(CGFloat) widthForTouch:(JotTouch*)touch{
    //
    // we divide by scale so that when the user is zoomed in,
    // their pen is always writing at the same visible scale
    //
    // this lets them write smaller text / detail when zoomed in
    return [[self activePen] widthForTouch:touch];
}

-(CGFloat) smoothnessForTouch:(JotTouch *)touch{
    return [[self activePen] smoothnessForTouch:touch];
}

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    return [rulerView willAddElementsToStroke:[[self activePen] willAddElementsToStroke:elements fromPreviousElement:previousElement] fromPreviousElement:previousElement];
}

#pragma mark - PolygonToolDelegate

-(void) beginShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool{
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page beginScissorAtPoint:adjustedPoint];
}

-(void) continueShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    if(![page continueScissorAtPoint:adjustedPoint]){
        [scissor cancelPolygonForTouch:touch];
    }
}

-(void) finishShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page finishScissorAtPoint:adjustedPoint];
}

-(void) cancelShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint adjustedPoint = [page convertPoint:adjusted fromView:rulerView];
    [page cancelScissorAtPoint:adjustedPoint];
}


#pragma mark - JotStylusManager Connection Notification

-(void)connectionChange:(NSNotification *) note{
    NSString *text;
    switch([[JotStylusManager sharedInstance] connectionStatus])
    {
        case JotConnectionStatusOff:
            text = @"Off";
            settingsButton.selected = NO;
            break;
        case JotConnectionStatusScanning:
            text = @"Scanning";
            settingsButton.selected = NO;
            break;
        case JotConnectionStatusPairing:
            text = @"Pairing";
            settingsButton.selected = NO;
            break;
        case JotConnectionStatusConnected:
            text = @"Connected";
            settingsButton.selected = YES;
            break;
        case JotConnectionStatusDisconnected:
            text = @"Disconnected";
            settingsButton.selected = NO;
            break;
        default:
            text = @"";
            settingsButton.selected = NO;
            break;
    }
//    debug_NSLog(@"jot status: %@", text);
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
}


#pragma mark - Gestures for List View

-(void) beginUITransitionFromPageView{
    [super beginUITransitionFromPageView];
    [[[MMPageCacheManager sharedInstance] currentEditablePage] cancelCurrentStrokeIfAny];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

-(void) beginUITransitionFromListView{
    [super beginUITransitionFromListView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
}

-(void) finishUITransitionToListView{
    [super finishUITransitionToListView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

-(void) finishUITransitionToPageView{
    [super finishUITransitionToPageView];
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:YES];
    [[visibleStackHolder peekSubview] updateThumbnailVisibility];
}

-(void) disableAllGesturesForPageView{
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:NO];
    [super disableAllGesturesForPageView];
}

-(void) enableAllGesturesForPageView{
    [[MMDrawingTouchGestureRecognizer sharedInstance] setEnabled:YES];
    [super enableAllGesturesForPageView];
}

#pragma mark - Sidebar Hit Test

-(BOOL) shouldPrioritizeSidebarButtonsForTaps{
    return self.isShowingPageView;
}

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if([self shouldPrioritizeSidebarButtonsForTaps]){
        for(int i=0;i<10;i++){
            if(CGRectContainsPoint(buttons[i].originalRect, point)){
                return (__bridge UIView*) buttons[i].button;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - Check for Active Gestures

-(BOOL) isActivelyGesturing{
    return [super isActivelyGesturing] || [[MMDrawingTouchGestureRecognizer sharedInstance] isDrawing];
}

@end
