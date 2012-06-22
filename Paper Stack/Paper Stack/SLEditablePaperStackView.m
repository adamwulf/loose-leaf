//
//  SLEditablePaperStackView.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLEditablePaperStackView.h"
#import "UIView+SubviewStacks.h"

@implementation SLEditablePaperStackView

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
    
    isFirstReading = YES;
    currentRawReading = 0;
    
    
    //    SLPopoverView* popover = [[SLPopoverView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
    //    [self addSubview:popover];
    
    //
    // sidebar buttons
    shareButton = [[SLShareButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    shareButton.delegate = self;
    [shareButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    pencilButton = [[SLPencilButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 2, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    pencilButton.delegate = self;
    [pencilButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pencilButton];
    
    textButton = [[SLTextButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 3, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    textButton.delegate = self;
    [textButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:textButton];
    
    insertImageButton = [[SLImageButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 4, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    insertImageButton.delegate = self;
    [insertImageButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:insertImageButton];
    
    polylineButton = [[SLPolylineButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 5, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    polylineButton.delegate = self;
    [polylineButton addTarget:self action:@selector(polylineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:polylineButton];
    
    polygonButton = [[SLPolygonButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 6, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    polygonButton.delegate = self;
    [polygonButton addTarget:self action:@selector(polygonButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:polygonButton];
    /*
     documentBackgroundSidebarButton = [[SLPaperButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 7, kWidthOfSidebarButton, kWidthOfSidebarButton)];
     documentBackgroundSidebarButton.delegate = self;
     documentBackgroundSidebarButton.enabled = NO;
     [documentBackgroundSidebarButton addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:documentBackgroundSidebarButton];
     */
    
    addPageSidebarButton = [[SLPlusButton alloc] initWithFrame:CGRectMake((kWidthOfSidebar - kWidthOfSidebarButton)/2, 232 + 60 * 8, kWidthOfSidebarButton, kWidthOfSidebarButton)];
    addPageSidebarButton.delegate = self;
    [addPageSidebarButton addTarget:self action:@selector(addPageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addPageSidebarButton];
    
    
    
    
    //
    // accelerometer for rotating buttons
    NSOperationQueue* opQueue = [[NSOperationQueue alloc] init];
    [opQueue setMaxConcurrentOperationCount:1];
    CMMotionManager* motionManager = [[CMMotionManager alloc] init];
    [motionManager setAccelerometerUpdateInterval:0.03];
    [motionManager startAccelerometerUpdatesToQueue:opQueue withHandler:^(CMAccelerometerData* data, NSError* error){
        //
        // if z == -1, x == 0, y == 0
        //   then it's flat up on a table
        // if z == 1, x == 0, y == 0
        //   then it's flat down on a table
        // if z == 0, x == 0, y == -1
        //   then it's up in portrait
        // if z == 0, x == 0, y == 1
        //   then it's upside down in portrait
        // if z == 0, x == 1, y == 0
        //   then it's landscape button left
        // if z == 0, x == -1, y == 0
        //   then it's landscape button right
        accelerationX = data.acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
        accelerationY = data.acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
        CGFloat newRawReading = atan2(accelerationY, accelerationX);
        if(ABS(newRawReading - currentRawReading) > .05 || isFirstReading){
            currentRawReading = newRawReading;
            isFirstReading = NO;
            [NSThread performBlockOnMainThread:^{
                addPageSidebarButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                documentBackgroundSidebarButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                polylineButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                polygonButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                insertImageButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                textButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                pencilButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                shareButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
            }];
        }
    }];
}

-(CGFloat) sidebarButtonRotation{
    return -(currentRawReading + M_PI/2);
}



#pragma mark - Button Actions

-(void) toggleButton:(UIButton*) _button{
    _button.enabled = !_button.enabled;
}

-(void) addPageButtonTapped:(UIButton*)_button{
    SLPaperView* page = [[SLPaperView alloc] initWithFrame:hiddenStackHolder.bounds];
    page.isBrandNewPage = YES;
    page.delegate = self;
    [hiddenStackHolder addSubviewToBottomOfStack:page];
    [[visibleStackHolder peekSubview] enableAllGestures];
    [self popTopPageOfHiddenStack]; 
}

-(void) polylineButtonTapped:(UIButton*)_button{
    debug_NSLog(@"polyline");
}

-(void) polygonButtonTapped:(UIButton*) _button{
    debug_NSLog(@"polygon");
}

-(void) insertImageButtonTapped:(UIButton*) _button{
    debug_NSLog(@"insert image");
}


@end
