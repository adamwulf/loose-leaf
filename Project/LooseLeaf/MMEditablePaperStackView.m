//
//  MMEditablePaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "UIView+SubviewStacks.h"

@implementation MMEditablePaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib{
    [super awakeFromNib];
    
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
    [handButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:handButton];
    
    CGRect rulerButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 6.5, kWidthOfSidebarButton, kWidthOfSidebarButton);
    rulerButton = [[MMRulerButton alloc] initWithFrame:rulerButtonFrame];
    rulerButton.delegate = self;
    [rulerButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
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


#pragma mark - Button Actions

-(void) penTapped:(UIButton*)_button{
    eraserButton.selected = NO;
    pencilButton.selected = YES;
}

-(void) eraserTapped:(UIButton*)_button{
    eraserButton.selected = YES;
    pencilButton.selected = NO;
}

/**
 * adds a new blank page to the visible stack
 * without changing the hidden stack's contents
 */
-(void) addPageButtonTapped:(UIButton*)_button{
    MMPaperView* page = [[MMPaperView alloc] initWithFrame:hiddenStackHolder.bounds];
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
    [self setButtonsVisible:NO];
    [super isBeginningToScaleReallySmall:page];
}
-(void) finishedScalingReallySmall:(MMPaperView *)page{
    [super finishedScalingReallySmall:page];
}
-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    [self setButtonsVisible:YES];
    [super cancelledScalingReallySmall:page];
}
-(void) finishedScalingBackToPageView:(MMPaperView*)page{
    [self setButtonsVisible:YES];
    [super finishedScalingBackToPageView:page];
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
