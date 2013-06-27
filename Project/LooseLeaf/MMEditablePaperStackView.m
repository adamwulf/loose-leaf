//
//  MMEditablePaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "UIView+SubviewStacks.h"

@implementation MMEditablePaperStackView{
    MMEditablePaperView* currentEditablePage;
    JotView* drawableView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        stackManager = [[MMStackManager alloc] initWithVisibleStack:visibleStackHolder andHiddenStack:hiddenStackHolder andBezelStack:bezelStackHolder];
        
        drawableView = [[JotView alloc] initWithFrame:self.bounds];
        drawableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.3];
        [[JotStylusManager sharedInstance] setPalmRejectorDelegate:drawableView];

        pen = [[Pen alloc] init];
        pen.shouldUseVelocity = YES;
        
        eraser = [[Eraser alloc] init];
        eraser.shouldUseVelocity = YES;
        
        // test code for custom popovers
        // ================================================================================
        //    MMPopoverView* popover = [[MMPopoverView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
        //    [self addSubview:popover];
        
        //
        // sidebar buttons
        // ================================================================================
        CGRect undoButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton);
        undoButton = [[MMUndoRedoButton alloc] initWithFrame:undoButtonFrame];
        undoButton.delegate = self;
        [undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        undoButton.reverseArrow = YES;
        [self addSubview:undoButton];
        
        CGRect redoButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, (kWidthOfSidebar - kWidthOfSidebarButton)/2 + 60, kWidthOfSidebarButton, kWidthOfSidebarButton);
        redoButton = [[MMUndoRedoButton alloc] initWithFrame:redoButtonFrame];
        redoButton.delegate = self;
        [redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
        
        
        
        
        
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
        
        
        
        
        
        
        
        
        addPageSidebarButton = [[MMPlusButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2 - 60, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        addPageSidebarButton.delegate = self;
        [addPageSidebarButton addTarget:self action:@selector(addPageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addPageSidebarButton];
        
        shareButton = [[MMShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, self.frame.size.height - kWidthOfSidebarButton - (kWidthOfSidebar - kWidthOfSidebarButton)/2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        shareButton.delegate = self;
        [shareButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
        
        
        
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
        handButton.selected = YES;
        
        polygonButton.enabled = NO;
        insertImageButton.enabled = NO;
        scissorButton.enabled = NO;
        
        [NSThread performBlockInBackground:^{
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
    }
}

-(void) redo:(UIButton*)_button{
    id obj = [visibleStackHolder peekSubview];
    if([obj respondsToSelector:@selector(redo)]){
        [obj redo];
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
        pencilButton.alpha = visible;
        scissorButton.alpha = visible;
        eraserButton.alpha = visible;
        shareButton.alpha = visible;
        mapButton.alpha = visible;
        redoButton.alpha = visible;
        undoButton.alpha = visible;
        rulerButton.alpha = visible;
        handButton.alpha = visible;
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
}

-(void) didSavePage:(MMPaperView*)page{
    NSLog(@"saved page: %@", page.uuid);
    if(page.scale < kMinPageZoom){
        if([page isKindOfClass:[MMEditablePaperView class]]){
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            if([editablePage hasEditsToSave]){
                NSLog(@"page still has edits to save...");
            }else{
                NSLog(@"page is done saving...");
                [(MMEditablePaperView*)page setCanvasVisible:NO];
                debug_NSLog(@"thumb for %@ is visible", page.uuid);
            }
        }
    }else{
        debug_NSLog(@"scale %f vs %f", page.scale, kMinPageZoom);
    }
}

#pragma mark - Page Loading and Unloading

-(void) mayChangeTopPageTo:(MMPaperView*)page{
    [super mayChangeTopPageTo:page];
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    [super willChangeTopPageTo:page];
    NSLog(@"validating top page");
}

-(void) didChangeTopPage{
    CheckMainThread;
    [super didChangeTopPage];
    NSLog(@"did change top page");
    MMPaperView* topPage = [visibleStackHolder peekSubview];
    if([topPage isKindOfClass:[MMEditablePaperView class]]){
        MMEditablePaperView* editableTopPage = (MMEditablePaperView*)topPage;
        if(currentEditablePage != editableTopPage){
            [currentEditablePage setDrawableView:nil];
            [currentEditablePage setEditable:NO];
            [currentEditablePage setCanvasVisible:NO];
            
            currentEditablePage = editableTopPage;
            NSLog(@"guys, gotta check this out");
        }
        if([currentEditablePage isKindOfClass:[MMEditablePaperView class]]){
            [currentEditablePage setDrawableView:drawableView];
            [currentEditablePage setCanvasVisible:YES];
            [currentEditablePage setEditable:YES];
        }
    }
}

-(void) willNotChangeTopPageTo:(MMPaperView*)page{
    [super willNotChangeTopPageTo:page];
}


-(void) saveStacksToDisk{
    [stackManager saveToDisk];
}

-(void) loadStacksFromDisk{
    NSDictionary* pages = [stackManager loadFromDiskWithBounds:self.bounds];
    for(MMPaperView* page in [[pages objectForKey:@"visiblePages"] reverseObjectEnumerator]){
        debug_NSLog(@"loaded: %@", [page description]);
        [self addPaperToBottomOfStack:page];
    }
    for(MMPaperView* page in [[pages objectForKey:@"hiddenPages"] reverseObjectEnumerator]){
        debug_NSLog(@"loaded hidden: %@", [page description]);
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

@end
