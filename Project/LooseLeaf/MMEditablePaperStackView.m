//
//  MMEditablePaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "UIView+SubviewStacks.h"
#import "TestFlight.h"
#import "MMRulerView.h"
#import "MMScrappedPaperView.h"
#import "MMScrapBubbleButton.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMPaperState.h"

@implementation MMEditablePaperStackView{
    MMEditablePaperView* currentEditablePage;
    JotView* drawableView;
    NSMutableArray* stateLoadedPages;
    UIPopoverController* jotTouchPopover;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.delegate = self;
        
        pagesWithLoadedCacheImages = [NSMutableSet set];
        stateLoadedPages = [NSMutableArray array];
        
        stackManager = [[MMStackManager alloc] initWithVisibleStack:visibleStackHolder andHiddenStack:hiddenStackHolder andBezelStack:bezelStackHolder];
        
        drawableView = [[JotView alloc] initWithFrame:self.bounds];
        [[JotStylusManager sharedInstance] setPalmRejectorDelegate:drawableView];

        pen = [[Pen alloc] init];
        
        eraser = [[Eraser alloc] init];
        
        polygon = [[PolygonTool alloc] init];
        polygon.delegate = self;
        
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
        
        shareButton = [[MMShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        shareButton.delegate = self;
        [shareButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:shareButton];
        
        settingsButton = [[MMAdonitButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        settingsButton.delegate = self;
        [settingsButton addTarget:self action:@selector(jotSettingsTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingsButton];
        
        
        
        
        pencilTool = [[MMPencilAndPaletteView alloc] initWithButtonFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar, kWidthOfSidebarButton, kWidthOfSidebarButton) andScreenSize:self.bounds.size];
        pencilTool.delegate = self;
        [self addSubview:pencilTool];
        
        eraserButton = [[MMPencilEraserButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        eraserButton.delegate = self;
        [eraserButton addTarget:self action:@selector(eraserTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:eraserButton];
        
        polygonButton = [[MMPolygonButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        polygonButton.delegate = self;
        [polygonButton addTarget:self action:@selector(polygonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:polygonButton];
        
        insertImageButton = [[MMImageButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        insertImageButton.delegate = self;
        [insertImageButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:insertImageButton];
        
        CGRect scissorButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 4, kWidthOfSidebarButton, kWidthOfSidebarButton);
        scissorButton = [[MMScissorButton alloc] initWithFrame:scissorButtonFrame];
        scissorButton.delegate = self;
        [scissorButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:scissorButton];
        
        
        
        
        CGRect handButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 5.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        handButton = [[MMHandButton alloc] initWithFrame:handButtonFrame];
        handButton.delegate = self;
        [handButton addTarget:self action:@selector(handTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:handButton];
        
        CGRect rulerButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 6.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
        rulerButton = [[MMRulerButton alloc] initWithFrame:rulerButtonFrame];
        rulerButton.delegate = self;
        [rulerButton addTarget:self action:@selector(rulerTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rulerButton];
        
        
        
        
        
        
        undoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2 - 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        undoButton.delegate = self;
        [undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        undoButton.reverseArrow = YES;
        [self addSubview:undoButton];
        
        redoButton = [[MMUndoRedoButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        redoButton.delegate = self;
        [redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
       
        
        
        
        
        //
        // accelerometer for rotating buttons
        // ================================================================================
        
        [[MMRotationManager sharedInstace] setDelegate:self];
        
        
        
        
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
        
        insertImageButton.enabled = NO;
        scissorButton.enabled = NO;
        shareButton.enabled = NO;
        
        [NSThread performBlockInBackground:^{
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector:@selector(connectionChange:)
                                                         name: JotStylusManagerDidChangeConnectionStatus
                                                       object:nil];
            [[JotStylusManager sharedInstance] setEnabled:YES];
            [[JotStylusManager sharedInstance] setRejectMode:NO];
        }];
        
        
        rulerView = [[MMRulerView alloc] initWithFrame:self.bounds];
        [self addSubview:rulerView];
        
        
        [self addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstace]];
    }
    return self;
}

/**
 * returns the value in radians that the sidebar buttons
 * should be rotated to stay pointed "down"
 */
-(CGFloat) sidebarButtonRotation{
    return -([[MMRotationManager sharedInstace] currentRotationReading] + M_PI/2);
}

-(Tool*) activePen{
    if(polygonButton.selected){
        return polygon;
    }else if(eraserButton.selected){
        return eraser;
    }else{
        return pen;
    }
}

#pragma mark - MMPencilAndPaletteViewDelegate

-(void) penTapped:(UIButton*)_button{
    eraserButton.selected = NO;
    pencilTool.selected = YES;
    polygonButton.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

-(void) colorMenuToggled{
    // noop
}

-(void) didChangeColorTo:(UIColor*)color{
    pen.color = color;
    if(!pencilTool.selected){
        [self penTapped:nil];
    }
}

#pragma mark - Tool Button Actions

-(void) undo:(UIButton*)_button{
    id obj = [visibleStackHolder peekSubview];
    if([obj respondsToSelector:@selector(undo)]){
        [obj undo];
        [TestFlight passCheckpoint:@"BUTTON_UNDO"];
    }
}

-(void) redo:(UIButton*)_button{
    id obj = [visibleStackHolder peekSubview];
    if([obj respondsToSelector:@selector(redo)]){
        [obj redo];
        [TestFlight passCheckpoint:@"BUTTON_REDO"];
    }
}

-(void) eraserTapped:(UIButton*)_button{
    eraserButton.selected = YES;
    pencilTool.selected = NO;
    polygonButton.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

-(void) polygonTapped:(UIButton*)_button{
    eraserButton.selected = NO;
    pencilTool.selected = NO;
    polygonButton.selected = YES;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
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
    if(jotTouchPopover && jotTouchPopover.popoverVisible){
        return;
    }else if(jotTouchPopover){
        [jotTouchPopover dismissPopoverAnimated:NO];
    }
    JotSettingsViewController* settings = [[JotSettingsViewController alloc] initWithOnOffSwitch: YES];
    jotTouchPopover = [[UIPopoverController alloc] initWithContentViewController:settings];
    [jotTouchPopover presentPopoverFromRect:_button.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    [jotTouchPopover setPopoverContentSize:CGSizeMake(300, 446) animated:NO];
}


#pragma mark - Page/Save Button Actions

/**
 * adds a new blank page to the visible stack
 * without changing the hidden stack's contents
 */
-(void) addPageButtonTapped:(UIButton*)_button{
    MMEditablePaperView* page = [[MMScrappedPaperView alloc] initWithFrame:hiddenStackHolder.bounds];
    page.isBrandNewPage = YES;
    page.delegate = self;
    [hiddenStackHolder pushSubview:page];
    [[visibleStackHolder peekSubview] enableAllGestures];
    [self popTopPageOfHiddenStack];
    [TestFlight passCheckpoint:@"BUTTON_ADD_PAGE"];
}

-(void) tempButtonTapped:(UIButton*)_button{
    debug_NSLog(@"temp button");
}

-(void) setButtonsVisible:(BOOL)visible{
    [UIView animateWithDuration:0.3 animations:^{
        addPageSidebarButton.alpha = visible;
        documentBackgroundSidebarButton.alpha = visible;
        polylineButton.alpha = visible;
        polygonButton.alpha = visible;
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

-(void) didUpdateAccelerometerWithReading:(CGFloat)currentRawReading{
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
    addPageSidebarButton.transform = rotationTransform;
    documentBackgroundSidebarButton.transform = rotationTransform;
    polylineButton.transform = rotationTransform;
    polygonButton.transform = rotationTransform;
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
}
-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
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


#pragma mark - Bezel Left and Right Gestures

-(void) isBezelingInLeftWithGesture:(MMBezelInLeftGestureRecognizer*)bezelGesture{
    if(bezelGesture.state == UIGestureRecognizerStateBegan){
        // cancel any strokes that this gesture is using
        for(UITouch* touch in bezelGesture.touches){
            [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
            [polygon cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInLeftWithGesture:bezelGesture];
}

-(void) isBezelingInRightWithGesture:(MMBezelInRightGestureRecognizer *)bezelGesture{
    if(bezelGesture.state == UIGestureRecognizerStateBegan){
        // cancel any strokes that this gesture is using
        for(UITouch* touch in bezelGesture.touches){
            [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
            [polygon cancelPolygonForTouch:touch];
        }
    }
    [super isBezelingInRightWithGesture:bezelGesture];
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
        [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
        [polygon cancelPolygonForTouch:touch];
    }
    
    return [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
}

#pragma mark = List View

-(void) isBeginningToScaleReallySmall:(MMPaperView *)page{
    // make sure the currently edited page is being saved
    // to disk if need be
    if([page isKindOfClass:[MMEditablePaperView class]]){
        __block MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        [pageToSave setEditable:NO];
        debug_NSLog(@"page %@ isn't editable", pageToSave.uuid);
        [[visibleStackHolder peekSubview] saveToDisk];
    }else{
        debug_NSLog(@"would save, but can't b/c its readonly page");
    }
    // update UI for scaling small into list view
    [self setButtonsVisible:NO];
    [super isBeginningToScaleReallySmall:page];
    [self updateVisiblePageImageCache];
}
-(void) finishedScalingReallySmall:(MMPaperView *)page{
    [super finishedScalingReallySmall:page];
    [self saveStacksToDisk];
    [TestFlight passCheckpoint:@"NAV_TO_LIST_FROM_PAGE"];
    [rulerView setHidden:YES];
}
-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    [self setButtonsVisible:YES];
    [super cancelledScalingReallySmall:page];

    // ok, we've zoomed into this page now
    if([page isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* pageToSave = (MMEditablePaperView*)page;
        [pageToSave setCanvasVisible:YES];
        [pageToSave setEditable:YES];
        debug_NSLog(@"page %@ is editable", pageToSave.uuid);
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
        [editablePage setCanvasVisible:NO];
        [editablePage setEditable:NO];
    }
    [TestFlight passCheckpoint:@"NAV_TO_PAGE_FROM_LIST"];
}

#pragma mark = Saving and Editing

-(void) didSavePage:(MMPaperView*)page{
    if(page.scale < kMinPageZoom){
        if([page isKindOfClass:[MMEditablePaperView class]]){
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            if([editablePage hasEditsToSave]){
                debug_NSLog(@"page still has edits to save...");
            }else{
                debug_NSLog(@"page is done saving...");
                [(MMEditablePaperView*)page setCanvasVisible:NO];
                [(MMEditablePaperView*)page setEditable:NO];
                debug_NSLog(@"thumb for %@ is visible", page.uuid);
            }
        }
    }else{
        // only load top page not in list view
        [self ensureTopPageIsLoaded:[visibleStackHolder peekSubview]];
    }
}

-(BOOL) isPageEditable:(MMPaperView*)page{
    return page == currentEditablePage;
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
    for(UITouch* touch in gesture.touches){
        [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
        [polygon cancelPolygonForTouch:touch];
    }
    [rulerView updateLineAt:[gesture point1InView:rulerView] to:[gesture point2InView:rulerView]
           startingDistance:[gesture initialDistance]];
}

-(void) didStopRuler:(MMRulerToolGestureRecognizer *)gesture{
    [rulerView liftRuler];
}

#pragma mark - Page Loading and Unloading

-(void) loadStateForPage:(MMPaperView*)page{
    [stateLoadedPages removeObject:page];
    [stateLoadedPages insertObject:page atIndex:0];
    if(currentEditablePage){
        [stateLoadedPages removeObject:currentEditablePage];
        [stateLoadedPages insertObject:currentEditablePage atIndex:0];
    }
    if([stateLoadedPages count] > 5){
        [[stateLoadedPages lastObject] unloadState];
        [stateLoadedPages removeLastObject];
    }
    if([page isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
        [editablePage loadStateAsynchronously:YES withSize:[drawableView pagePixelSize] andContext:[drawableView context] andStartPage:NO];
    }
}

-(void) ensureTopPageIsLoaded:(MMPaperView*)topPage{
    if([topPage isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* editableTopPage = (MMEditablePaperView*)topPage;
        
        if(currentEditablePage != editableTopPage){
            // only care if the page is changing
            if(![currentEditablePage hasEditsToSave] && [editableTopPage hasStateLoaded]){
                // the outgoing page is saved to disk
                // and the incoming page has its
                // state loaded
                [currentEditablePage setDrawableView:nil];
                [currentEditablePage setEditable:NO];
                [currentEditablePage setCanvasVisible:NO];
                currentEditablePage = editableTopPage;
                debug_NSLog(@"did switch top page to %@", currentEditablePage.uuid);
                [currentEditablePage setDrawableView:drawableView];
            }else{
                debug_NSLog(@"load state for future top page: %@", editableTopPage.uuid);
                [self loadStateForPage:editableTopPage];
            }
        }else{
            // just double check that we're in editable state
            [currentEditablePage setDrawableView:drawableView];
        }
    }
}

-(void) mayChangeTopPageTo:(MMPaperView*)page{
    if([visibleStackHolder containsSubview:page]){
        MMPaperView* pageBelow = [visibleStackHolder getPageBelow:page];
        if([pageBelow isKindOfClass:[MMEditablePaperView class]]){
            [(MMEditablePaperView*)pageBelow loadCachedPreview];
            [pagesWithLoadedCacheImages addObject:pageBelow];
        }
    }
    if([page isKindOfClass:[MMEditablePaperView class]]){
        [(MMEditablePaperView*)page loadCachedPreview];
        [pagesWithLoadedCacheImages addObject:page];
        if([bezelStackHolder.subviews count] > 6){
            MMPaperView* page = [bezelStackHolder.subviews objectAtIndex:[bezelStackHolder.subviews count] - 6];
            if([page isKindOfClass:[MMEditablePaperView class]]){
                // we have a pretty impressive bezel going on here,
                // so start to unload the pages that are pretty much
                // invisible in the bezel stack
                [(MMEditablePaperView*)page unloadCachedPreview];
            }
        }
    }
    if(page && ![recentlySuggestedPageUUID isEqualToString:page.uuid]){
        [self loadStateForPage:page];
    }
    [super mayChangeTopPageTo:page];
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    if(page && ![recentlyConfirmedPageUUID isEqualToString:page.uuid]){
        [self loadStateForPage:page];
    }
    [super willChangeTopPageTo:page];
}

-(void) didChangeTopPage{
    CheckMainThread;
    [super didChangeTopPage];
    MMPaperView* topPage = [visibleStackHolder peekSubview];
    [self ensureTopPageIsLoaded:topPage];
    [self updateVisiblePageImageCache];
}

-(void) willNotChangeTopPageTo:(MMPaperView*)page{
    [super willNotChangeTopPageTo:page];
    debug_NSLog(@"won't change to: %@", page.uuid);
}


-(void) saveStacksToDisk{
    [stackManager saveToDisk];
}

-(void) loadStacksFromDisk{
    NSDictionary* pages = [stackManager loadFromDiskWithBounds:self.bounds];
    for(MMPaperView* page in [[pages objectForKey:@"visiblePages"] reverseObjectEnumerator]){
        [self addPaperToBottomOfStack:page];
    }
    for(MMPaperView* page in [[pages objectForKey:@"hiddenPages"] reverseObjectEnumerator]){
        [self addPaperToBottomOfHiddenStack:page];
    }
    
    BOOL isStart = NO;
    
    if(![self hasPages]){
        isStart = YES;
        for(int i=0;i<1;i++){
            MMEditablePaperView* editable = [[MMScrappedPaperView alloc] initWithFrame:self.bounds];
            [editable setEditable:YES];
            [self addPaperToBottomOfStack:editable];
            MMEditablePaperView* paper = [[MMScrappedPaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfStack:paper];
            paper = [[MMScrappedPaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfHiddenStack:paper];
            paper = [[MMScrappedPaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfHiddenStack:paper];
        }
        [self saveStacksToDisk];
    }
    
    // load the state for the top page in the visible stack
    [[visibleStackHolder peekSubview] loadStateAsynchronously:NO
                                                     withSize:[drawableView pagePixelSize]
                                                   andContext:[drawableView context]
                                                 andStartPage:isStart];
    
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

    if(isStart){
        [[visibleStackHolder peekSubview] saveToDisk];
    }
}

-(BOOL) hasPages{
    return [visibleStackHolder.subviews count] > 0;
}

#pragma mark - JotViewDelegate

-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
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
}

-(void) willCancelStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] willCancelStrokeWithTouch:touch];
}

-(void) didCancelStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] didCancelStrokeWithTouch:touch];
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

-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return [[self activePen] rotationForSegment:segment fromPreviousSegment:previousSegment];
}

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    return [rulerView willAddElementsToStroke:[[self activePen] willAddElementsToStroke:elements fromPreviousElement:previousElement] fromPreviousElement:previousElement];
}

#pragma mark - PolygonToolDelegate

-(void) beginShapeWithTouch:(UITouch*)touch{
    [rulerView willBeginStrokeAt:[touch locationInView:rulerView]];
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    [page beginShapeAtPoint:[page convertPoint:adjusted fromView:rulerView]];
}

-(void) continueShapeWithTouch:(UITouch*)touch{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    if(![page continueShapeAtPoint:[page convertPoint:adjusted fromView:rulerView]]){
        [polygon cancelPolygonForTouch:touch];
    }
}

-(void) finishShapeWithTouch:(UITouch*)touch{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    [page finishShapeAtPoint:[page convertPoint:adjusted fromView:rulerView]];
}

-(void) cancelShapeWithTouch:(UITouch*)touch{
    CGPoint adjusted = [rulerView adjustPoint:[touch locationInView:rulerView]];
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    [page cancelShapeAtPoint:[page convertPoint:adjusted fromView:rulerView]];
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
    debug_NSLog(@"jot status: %@", text);
}



#pragma mark - UIScrollViewDelegate

-(void) updateVisiblePageImageCache{
    CGPoint visibleScrollOffset;
    if(self.scrollEnabled){
        visibleScrollOffset = self.contentOffset;
    }else{
        visibleScrollOffset = initialScrollOffsetFromTransitionToListView;
    }
    NSArray* visiblePages = [self findPagesInVisibleRowsOfListViewGivenOffset:visibleScrollOffset];
    for(MMEditablePaperView* page in visiblePages){
        [page loadCachedPreview];
    }
    NSSet* invisiblePages = [pagesWithLoadedCacheImages objectsPassingTest:^BOOL(id obj, BOOL*stop){
        return ![visiblePages containsObject:obj];
    }];
    for(MMEditablePaperView* page in invisiblePages){
        [page unloadCachedPreview];
    }
    [pagesWithLoadedCacheImages addObjectsFromArray:visiblePages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateVisiblePageImageCache];
}


#pragma mark - MMEditablePaperViewDelegate

-(void) didLoadStateForPage:(MMEditablePaperView *)page{
    if(page == [visibleStackHolder peekSubview] || page == currentEditablePage){
//        NSLog(@"didLoadStateForPage: %@", page.uuid);
        if(page.scale > kMinPageZoom){
            [self ensureTopPageIsLoaded:[visibleStackHolder peekSubview]];
        }
    }
}

-(void) didUnloadStateForPage:(MMEditablePaperView*) page{
    if(page == [visibleStackHolder peekSubview] || page == currentEditablePage){
//        NSLog(@"didUnloadStateForPage: %@", page.uuid);
        if(page.scale > kMinPageZoom){
            [self ensureTopPageIsLoaded:[visibleStackHolder peekSubview]];
        }
    }
}

@end
