//
//  MMImageSlidingSidebarView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageSidebarContainerView.h"
#import "MMAlbumSidebarContentView.h"
#import "MMFaceSidebarContentView.h"
#import "MMEventSidebarContentView.h"
#import "MMCameraSidebarContentView.h"
#import "MMInboxContentView.h"
#import "MMPhotoManager.h"
#import "MMImageViewButton.h"
#import "MMFaceButton.h"
#import "MMPalmTreeButton.h"
#import "MMInboxButton.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "MMCameraButton.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"

@implementation MMImageSidebarContainerView{
    MMCameraSidebarContentView* cameraListContentView;
    MMAlbumSidebarContentView* albumListContentView;
    MMFaceSidebarContentView* faceListContentView;
    MMEventSidebarContentView* eventListContentView;
    MMInboxContentView* inboxListContent;
    
    NSArray* allListContentViews;
    
    MMCameraButton* cameraAlbumButton;
    MMImageViewButton* iPhotoAlbumButton;
    MMFaceButton* iPhotoFacesButton;
    MMPalmTreeButton* iPhotoEventsButton;
    MMInboxButton* inboxButton;
}

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft];
    if (self) {
        
        CGRect contentBounds = [slidingSidebarView contentBounds];
        
        [MMPhotoManager sharedInstance].delegate = self;
        
        CGRect buttonBounds = CGRectZero;
        buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
        buttonBounds.size.height = kWidthOfSidebarButton; // includes spacing buffer
        buttonBounds.size.width = kWidthOfSidebarButton * 5;
        buttonBounds.origin.x = (contentBounds.size.width - buttonBounds.size.width)/2 + 10;
        
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        
        // Initialization code
        //////////////////////////////////////////
        // content
        
        cameraListContentView = [[MMCameraSidebarContentView alloc] initWithFrame:contentBounds];
        cameraListContentView.delegate = self;
        [slidingSidebarView addSubview:cameraListContentView];
        
        albumListContentView = [[MMAlbumSidebarContentView alloc] initWithFrame:contentBounds];
        albumListContentView.delegate = self;
        [slidingSidebarView addSubview:albumListContentView];
        albumListContentView.hidden = YES;
        
        faceListContentView = [[MMFaceSidebarContentView alloc] initWithFrame:contentBounds];
        faceListContentView.delegate = self;
        [slidingSidebarView addSubview:faceListContentView];
        faceListContentView.hidden = YES;
        
        eventListContentView = [[MMEventSidebarContentView alloc] initWithFrame:contentBounds];
        eventListContentView.delegate = self;
        [slidingSidebarView addSubview:eventListContentView];
        eventListContentView.hidden = YES;
        
        inboxListContent = [[MMInboxContentView alloc] initWithFrame:contentBounds];
        inboxListContent.delegate = self;
        [slidingSidebarView addSubview:inboxListContent];
        inboxListContent.hidden = YES;
        
        
        allListContentViews = [NSArray arrayWithObjects:cameraListContentView,
                               albumListContentView, faceListContentView, eventListContentView,
                               inboxListContent, nil];
        //////////////////////////////////////////
        // buttons
        
        // camera
        cameraAlbumButton = [[MMCameraButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(buttonBounds)/2 - (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer)/2, buttonBounds.origin.y,
                                                                             kWidthOfSidebarButton, kWidthOfSidebarButton)];
        cameraAlbumButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        cameraAlbumButton.shadowInset = -1;
        [cameraAlbumButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [slidingSidebarView addSubview:cameraAlbumButton];
        
        // albums
        iPhotoAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(buttonBounds)/2 + (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer)/2, buttonBounds.origin.y,
                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoAlbumButton setImage:[UIImage imageNamed:@"clearphotoalbum"]];
        [iPhotoAlbumButton addTarget:self action:@selector(albumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoAlbumButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoAlbumButton.shadowInset = -1;
        [slidingSidebarView addSubview:iPhotoAlbumButton];
        
        // faces button
        iPhotoFacesButton = [[MMFaceButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                           kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoFacesButton addTarget:self action:@selector(faceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoFacesButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoFacesButton.shadowInset = -1;
//        [slidingSidebarView addSubview:iPhotoFacesButton];
        
        // event button
        iPhotoEventsButton = [[MMPalmTreeButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 3* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoEventsButton addTarget:self action:@selector(eventButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoEventsButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoEventsButton.shadowInset = -1;
//        [slidingSidebarView addSubview:iPhotoEventsButton];
        
        inboxButton = [[MMInboxButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [inboxButton addTarget:self action:@selector(inboxButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        inboxButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        inboxButton.shadowInset = -1;
//        [slidingSidebarView addSubview:inboxButton];
        
        [self highlightButton:cameraAlbumButton];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void) show:(BOOL)animated{
    [super show:animated];
    if(!cameraListContentView.hidden){
        [cameraListContentView show:animated];
    }
    if(!albumListContentView.hidden){
        [albumListContentView show:animated];
    }
    if(!faceListContentView.hidden){
        [faceListContentView show:animated];
    }
    if(!eventListContentView.hidden){
        [eventListContentView show:animated];
    }
    if(!inboxListContent.hidden){
        [inboxListContent show:animated];
    }
    [self updateInterfaceTo:[[MMRotationManager sharedInstance] lastBestOrientation] animated:NO];
}

-(void) hide:(BOOL)animated onComplete:(void (^)(BOOL))onComplete{
    [super hide:animated onComplete:^(BOOL finished){
        [cameraListContentView hide:animated];
        [albumListContentView hide:animated];
        [faceListContentView hide:animated];
        [eventListContentView hide:animated];
        [inboxListContent hide:animated];
        
        if(onComplete){
            onComplete(finished);
        }
    }];
}

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView{
    [self.delegate pictureTakeWithCamera:img fromView:cameraView];
}

-(void) photoWasTapped:(MMDisplayAsset *)asset fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(MMAbstractSidebarContentView *)container{
    [self.delegate photoWasTapped:asset fromView:bufferedImage withRotation:rotation fromContainer:[container description]];
}

-(void) switchToListView:(MMAbstractSidebarContentView*)listView{
    for(MMAbstractSidebarContentView* aListView in allListContentViews){
        if(aListView == listView){
            listView.hidden = NO;
            [listView reset:NO];
            [listView show:NO];
        }else if(!aListView.hidden){
            [aListView hide:NO];
            aListView.hidden = YES;
        }
    }
}

-(void) highlightButton:(MMSidebarButton*)button{
    iPhotoAlbumButton.selected = NO;
    iPhotoEventsButton.selected = NO;
    iPhotoFacesButton.selected = NO;
    cameraAlbumButton.selected = NO;
    inboxButton.selected = NO;
    button.selected = YES;
}

-(void) cameraButtonTapped:(MMSidebarButton*)button{
    [self switchToListView:cameraListContentView];
    [self highlightButton:button];
}

-(void) albumButtonTapped:(MMSidebarButton*)button{
    [self switchToListView:albumListContentView];
    [self highlightButton:button];
}

-(void) faceButtonTapped:(MMSidebarButton*)button{
    [self switchToListView:faceListContentView];
    [self highlightButton:button];
}

-(void) eventButtonTapped:(MMSidebarButton*)button{
    [self switchToListView:eventListContentView];
    [self highlightButton:button];
}

-(void) inboxButtonTapped:(MMSidebarButton*)button{
    [self switchToListView:inboxListContent];
    [self highlightButton:button];
}

-(void) showPDF:(MMInboxItem*)pdf{
    [self switchToListView:inboxListContent];
    [inboxListContent switchToPDFView:pdf];
    [self highlightButton:inboxButton];
}

-(void) refreshPDF{
    [inboxListContent reset:NO];
}

#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums;{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [cameraListContentView doneLoadingPhotoAlbums];
            [albumListContentView doneLoadingPhotoAlbums];
            [faceListContentView doneLoadingPhotoAlbums];
            [eventListContentView doneLoadingPhotoAlbums];
        }
    });
}

-(void) albumUpdated:(MMPhotoAlbum*)updatedAlbum{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [cameraListContentView albumUpdated:updatedAlbum];
            [albumListContentView albumUpdated:updatedAlbum];
            [faceListContentView albumUpdated:updatedAlbum];
            [eventListContentView albumUpdated:updatedAlbum];
        }
    });
}


#pragma mark - Rotation

-(CGFloat) sidebarButtonRotation{
    if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait){
        return 0;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft){
        return -M_PI_2;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight){
        return M_PI_2;
    }else{
        return M_PI;
    }
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation{
    [self updateInterfaceTo:orientation animated:YES];
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation animated:(BOOL)animated{
    if(![self isVisible]) return;
    if(!cameraListContentView.hidden){
        [cameraListContentView updatePhotoRotation:animated];
    }else if(!albumListContentView.hidden){
        [albumListContentView updatePhotoRotation:animated];
    }else if(!faceListContentView.hidden){
        [faceListContentView updatePhotoRotation:animated];
    }else if(!eventListContentView.hidden){
        [eventListContentView updatePhotoRotation:animated];
    }else if(!inboxListContent.hidden){
        [inboxListContent updatePhotoRotation:animated];
    }
    
    void(^animations)() = ^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        cameraAlbumButton.rotation = [self sidebarButtonRotation];
        cameraAlbumButton.transform = rotationTransform;
        
        iPhotoAlbumButton.rotation = [self sidebarButtonRotation];
        iPhotoAlbumButton.transform = rotationTransform;
        
        iPhotoFacesButton.rotation = [self sidebarButtonRotation];
        iPhotoFacesButton.transform = rotationTransform;
        
        iPhotoEventsButton.rotation = [self sidebarButtonRotation];
        iPhotoEventsButton.transform = rotationTransform;
        
        inboxButton.rotation = [self sidebarButtonRotation];
        inboxButton.transform = rotationTransform;
    };
    
    [[NSThread mainThread] performBlock:^{
        if(animated){
            [UIView animateWithDuration:.3 animations:animations];
        }else{
            animations();
        }
    }];
}


#pragma mark - Memory

-(void) killMemory{
    if(![self isVisible]){
        [cameraListContentView killMemory];
        [albumListContentView killMemory];
        [faceListContentView killMemory];
        [eventListContentView killMemory];
        [inboxListContent killMemory];
    }
}


@end
