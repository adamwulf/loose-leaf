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
    
    // test code for custom popovers
    // ================================================================================
    //    MMPopoverView* popover = [[MMPopoverView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
    //    [self addSubview:popover];
    
    //
    // sidebar buttons
    // ================================================================================
    shareButton = [[MMShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    shareButton.delegate = self;
    [shareButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    pencilButton = [[MMPencilButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    pencilButton.delegate = self;
    [pencilButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pencilButton];
    
    CGRect textButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton);
    ;
    textButton = [[MMTextButton alloc] initWithFrame:textButtonFrame andFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:28] andLetter:@"T" andXOffset:2];
    textButton.delegate = self;
    [textButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:textButton];
    
    insertImageButton = [[MMImageButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 4, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    insertImageButton.delegate = self;
    [insertImageButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:insertImageButton];
    
    polylineButton = [[MMPolylineButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 5, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    polylineButton.delegate = self;
    [polylineButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:polylineButton];
    
    polygonButton = [[MMPolygonButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 6, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    polygonButton.delegate = self;
    [polygonButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:polygonButton];
    /*
     documentBackgroundSidebarButton = [[MMPaperButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 7, kWidthOfSidebarButton, kWidthOfSidebarButton)];
     documentBackgroundSidebarButton.delegate = self;
     documentBackgroundSidebarButton.enabled = NO;
     [documentBackgroundSidebarButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:documentBackgroundSidebarButton];
    */
    
    mapButton = [[MMMapButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 7, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    mapButton.delegate = self;
    [mapButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mapButton];
    
    addPageSidebarButton = [[MMPlusButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar + 60 * 9, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    addPageSidebarButton.delegate = self;
    [addPageSidebarButton addTarget:self action:@selector(addPageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addPageSidebarButton];
    
    CGRect undoButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar - 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton);
    undoButton = [[MMTextButton alloc] initWithFrame:undoButtonFrame andFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:28] andLetter:@"<" andXOffset:2];
    undoButton.delegate = self;
    [undoButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:undoButton];

    CGRect redoButtonFrame = CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, kStartOfSidebar - 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton);
    redoButton = [[MMTextButton alloc] initWithFrame:redoButtonFrame andFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:28] andLetter:@">" andXOffset:2];
    redoButton.delegate = self;
    [redoButton addTarget:self action:@selector(tempButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:redoButton];

    //
    // accelerometer for rotating buttons
    // ================================================================================
    
    [[MMRotationManager sharedInstace] setDelegate:self];
}

/**
 * returns the value in radians that the sidebar buttons
 * should be rotated to stay pointed "down"
 */
-(CGFloat) sidebarButtonRotation{
    return -([[MMRotationManager sharedInstace] currentRotationReading] + M_PI/2);
}



#pragma mark - Button Actions


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
        shareButton.alpha = visible;
        mapButton.alpha = visible;
        redoButton.alpha = visible;
        undoButton.alpha = visible;
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
        pencilButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        shareButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        mapButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        undoButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        redoButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
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


@end
