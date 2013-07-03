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
#import "MMFeedbackView.h"

@implementation MMEditablePaperStackView{
    MMEditablePaperView* currentEditablePage;
    JotView* drawableView;
    NSMutableArray* stateLoadedPages;
    MMFeedbackView* feedbackView;
    UIPopoverController* jotTouchPopover;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        stateLoadedPages = [NSMutableArray array];
        
        stackManager = [[MMStackManager alloc] initWithVisibleStack:visibleStackHolder andHiddenStack:hiddenStackHolder andBezelStack:bezelStackHolder];
        
        drawableView = [[JotView alloc] initWithFrame:self.bounds];
        [[JotStylusManager sharedInstance] setPalmRejectorDelegate:drawableView];

        pen = [[Pen alloc] init];
        
        eraser = [[Eraser alloc] init];
        
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
        
        feedbackButton = [[MMLikeButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60*2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        feedbackButton.delegate = self;
        [feedbackButton addTarget:self action:@selector(feedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:feedbackButton];
        
        settingsButton = [[MMAdonitButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        settingsButton.delegate = self;
        [settingsButton addTarget:self action:@selector(jotSettingsTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingsButton];
        
        
        
        
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        pencilButton.delegate = self;
        [pencilButton addTarget:self action:@selector(penTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pencilButton];
        
        eraserButton = [[MMPencilEraserButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        eraserButton.delegate = self;
        [eraserButton addTarget:self action:@selector(eraserTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:eraserButton];
        
        polygonButton = [[MMPolygonButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        polygonButton.delegate = self;
        [polygonButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
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
        
        
        pencilButton.selected = YES;
//        handButton.selected = YES;
        
        polygonButton.enabled = NO;
        insertImageButton.enabled = NO;
        scissorButton.enabled = NO;
        handButton.enabled = NO;
        rulerButton.enabled = NO;
        shareButton.enabled = NO;
        
        [NSThread performBlockInBackground:^{
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector:@selector(connectionChange:)
                                                         name: JotStylusManagerDidChangeConnectionStatus
                                                       object:nil];
            [[JotStylusManager sharedInstance] setEnabled:YES];
            [[JotStylusManager sharedInstance] setRejectMode:NO];
        }];
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

-(Pen*) activePen{
    if(eraserButton.selected){
        return eraser;
    }else{
        return pen;
    }
}

#pragma mark - Undo/Redo Button Actions

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


#pragma mark - Tool Button Actions

-(void) penTapped:(UIButton*)_button{
    eraserButton.selected = NO;
    pencilButton.selected = YES;
    polygonButton.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}

-(void) eraserTapped:(UIButton*)_button{
    eraserButton.selected = YES;
    pencilButton.selected = NO;
    polygonButton.selected = NO;
    insertImageButton.selected = NO;
    scissorButton.selected = NO;
}


#pragma mark - Gesture Button Actions

-(void) handTapped:(UIButton*)_button{
    handButton.selected = YES;
    rulerButton.selected = NO;
}

-(void) rulerTapped:(UIButton*)_button{
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
    MMEditablePaperView* page = [[MMEditablePaperView alloc] initWithFrame:hiddenStackHolder.bounds];
    page.isBrandNewPage = YES;
    page.delegate = self;
    [hiddenStackHolder pushSubview:page];
    [[visibleStackHolder peekSubview] enableAllGestures];
    [self popTopPageOfHiddenStack];
    [TestFlight passCheckpoint:@"BUTTON_ADD_PAGE"];
}

-(void) feedbackButtonTapped:(UIButton*)_button{
    CGRect feedbackFrame = CGRectInset(self.bounds, 150, 200);
    feedbackFrame.size.height -= 30;
    if(!feedbackView){
        feedbackView = [[MMFeedbackView alloc] initWithFrame:feedbackFrame];
    }
    feedbackView.frame = feedbackFrame;
    [self addSubview:feedbackView];
    [feedbackView show];
}

-(void) tempButtonTapped:(UIButton*)_button{
    debug_NSLog(@"temp button");
}

-(void) setButtonsVisible:(BOOL)visible{
    [UIView animateWithDuration:0.3 animations:^{
        addPageSidebarButton.alpha = visible;
        feedbackButton.alpha = visible;
        documentBackgroundSidebarButton.alpha = visible;
        polylineButton.alpha = visible;
        polygonButton.alpha = visible;
        insertImageButton.alpha = visible;
        textButton.alpha = visible;
        pencilButton.alpha = visible;
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
    [NSThread performBlockOnMainThread:^{
        addPageSidebarButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        documentBackgroundSidebarButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        polylineButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        polygonButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        insertImageButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        textButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        scissorButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        pencilButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        eraserButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        shareButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        mapButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        undoButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        redoButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        rulerButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        handButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        feedbackButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        settingsButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
    }];
}

-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    // noop
}

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    // noop
}

#pragma mark - MMPaperViewDelegate - List View

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
}
-(void) finishedScalingReallySmall:(MMPaperView *)page{
    [super finishedScalingReallySmall:page];
    [self saveStacksToDisk];
    [TestFlight passCheckpoint:@"NAV_TO_LIST_FROM_PAGE"];
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
}
-(void) finishedScalingBackToPageView:(MMPaperView*)page{
    [self setButtonsVisible:YES];
    [super finishedScalingBackToPageView:page];
    [self saveStacksToDisk];
    [TestFlight passCheckpoint:@"NAV_TO_PAGE_FROM_LIST"];
}

-(void) didSavePage:(MMPaperView*)page{
    if(page.scale < kMinPageZoom){
        if([page isKindOfClass:[MMEditablePaperView class]]){
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            if([editablePage hasEditsToSave]){
                debug_NSLog(@"page still has edits to save...");
            }else{
                debug_NSLog(@"page is done saving...");
                [(MMEditablePaperView*)page setCanvasVisible:NO];
                debug_NSLog(@"thumb for %@ is visible", page.uuid);
            }
        }
    }
}

-(BOOL) isPageEditable:(MMPaperView*)page{
    return page == currentEditablePage;
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
        [editablePage loadStateAsynchronously:YES withSize:[drawableView pagePixelSize] andContext:[drawableView context] andThen:nil];
    }
}

-(void) ensureTopPageIsLoaded:(MMPaperView*)topPage{
    if([topPage isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* editableTopPage = (MMEditablePaperView*)topPage;
        if(currentEditablePage != editableTopPage){
            [currentEditablePage setDrawableView:nil];
            [currentEditablePage setEditable:NO];
            [currentEditablePage setCanvasVisible:NO];
            currentEditablePage = editableTopPage;
            debug_NSLog(@"did switch top page to %@", currentEditablePage.uuid);
        }
        if([currentEditablePage isKindOfClass:[MMEditablePaperView class]]){
            [self loadStateForPage:currentEditablePage];
            [currentEditablePage setDrawableView:drawableView];
        }
    }
}

-(void) mayChangeTopPageTo:(MMPaperView*)page{
    [super mayChangeTopPageTo:page];
    [self loadStateForPage:page];
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    [super willChangeTopPageTo:page];
    debug_NSLog(@"will switch top page to %@", page.uuid);
    [self loadStateForPage:page];
}

-(void) didChangeTopPage{
    CheckMainThread;
    [super didChangeTopPage];
    debug_NSLog(@"did change top page");
    MMPaperView* topPage = [visibleStackHolder peekSubview];
    [self ensureTopPageIsLoaded:topPage];
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
    
    if(![self hasPages]){
        for(int i=0;i<1;i++){
            MMEditablePaperView* editable = [[MMEditablePaperView alloc] initWithFrame:self.bounds];
            [editable setEditable:YES];
            [self addPaperToBottomOfStack:editable];
            MMEditablePaperView* paper = [[MMEditablePaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfStack:paper];
            paper = [[MMEditablePaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfHiddenStack:paper];
            paper = [[MMEditablePaperView alloc] initWithFrame:self.bounds];
            [self addPaperToBottomOfHiddenStack:paper];
        }
        [self saveStacksToDisk];
    }
    
    
    [[visibleStackHolder peekSubview] loadStateAsynchronously:NO
                                                     withSize:[drawableView pagePixelSize]
                                                   andContext:[drawableView context]
                                                      andThen:nil];
    
    [self willChangeTopPageTo:[visibleStackHolder peekSubview]];
    [self didChangeTopPage];
}

-(BOOL) hasPages{
    return [visibleStackHolder.subviews count] > 0;
}

#pragma mark - JotViewDelegate

-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    return [[self activePen] willBeginStrokeWithTouch:touch];
}

-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] willMoveStrokeWithTouch:touch];
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    [[self activePen] didEndStrokeWithTouch:touch];
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
    return [[self activePen] rotationForSegment:segment fromPreviousSegment:previousSegment];;
}


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
@end
