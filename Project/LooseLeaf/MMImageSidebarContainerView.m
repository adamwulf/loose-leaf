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
#import "MMPDFInboxContentView.h"
#import "MMPhotoManager.h"
#import "MMImageViewButton.h"
#import "MMFaceButton.h"
#import "MMPalmTreeButton.h"
#import "MMPDFButton.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"

@implementation MMImageSidebarContainerView{
    MMCameraSidebarContentView* cameraListContentView;
    MMAbstractSidebarContentView* albumListContentView;
    MMAbstractSidebarContentView* faceListContentView;
    MMEventSidebarContentView* eventListContentView;
    MMPDFInboxContentView* pdfListContentView;
    
    NSArray* allListContentViews;
    
    MMImageViewButton* cameraAlbumButton;
    MMImageViewButton* iPhotoAlbumButton;
    MMFaceButton* iPhotoFacesButton;
    MMPalmTreeButton* iPhotoEventsButton;
    MMPDFButton* pdfInboxButton;
    MMImageViewButton* twitterAlbumButton;
    MMImageViewButton* facebookAlbumButton;
    MMImageViewButton* evernoteAlbumButton;
}

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft];
    if (self) {
        
        CGRect contentBounds = [sidebarContentView contentBounds];

        [MMPhotoManager sharedInstace].delegate = self;

        CGRect buttonBounds = contentBounds;
        buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
        buttonBounds.size.height = kWidthOfSidebarButton; // includes spacing buffer
        
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        
        // Initialization code
        //////////////////////////////////////////
        // content
        
        cameraListContentView = [[MMCameraSidebarContentView alloc] initWithFrame:contentBounds];
        cameraListContentView.delegate = self;
        [sidebarContentView addSubview:cameraListContentView];

        albumListContentView = [[MMAlbumSidebarContentView alloc] initWithFrame:contentBounds];
        albumListContentView.delegate = self;
        [sidebarContentView addSubview:albumListContentView];
        albumListContentView.hidden = YES;
        
        faceListContentView = [[MMFaceSidebarContentView alloc] initWithFrame:contentBounds];
        faceListContentView.delegate = self;
        [sidebarContentView addSubview:faceListContentView];
        faceListContentView.hidden = YES;
        
        eventListContentView = [[MMEventSidebarContentView alloc] initWithFrame:contentBounds];
        eventListContentView.delegate = self;
        [sidebarContentView addSubview:eventListContentView];
        eventListContentView.hidden = YES;
        
        pdfListContentView = [[MMPDFInboxContentView alloc] initWithFrame:contentBounds];
        pdfListContentView.delegate = self;
        [sidebarContentView addSubview:pdfListContentView];
        pdfListContentView.hidden = YES;
        
        
        allListContentViews = [NSArray arrayWithObjects:cameraListContentView,
                               albumListContentView, faceListContentView, eventListContentView,
                               pdfListContentView, nil];
        //////////////////////////////////////////
        // buttons
        
        // camera
        cameraAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        cameraAlbumButton.darkBg = YES;
        [cameraAlbumButton setImage:[UIImage imageNamed:@"clearcamera"]];
        [cameraAlbumButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:cameraAlbumButton];

        // albums
        iPhotoAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoAlbumButton setImage:[UIImage imageNamed:@"clearphotoalbum"]];
        [iPhotoAlbumButton addTarget:self action:@selector(albumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:iPhotoAlbumButton];
        
        // faces button
        iPhotoFacesButton = [[MMFaceButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoFacesButton addTarget:self action:@selector(faceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:iPhotoFacesButton];
        
        // event button
        iPhotoEventsButton = [[MMPalmTreeButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 3* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                    kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [iPhotoEventsButton addTarget:self action:@selector(eventButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:iPhotoEventsButton];
        
        pdfInboxButton = [[MMPDFButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [pdfInboxButton addTarget:self action:@selector(pdfButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:pdfInboxButton];
        
//        // facebook
//        facebookAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4*kWidthOfSidebarButton, buttonBounds.origin.y,
//                                                                                 kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        [facebookAlbumButton setImage:[UIImage imageNamed:@"facebook"]];
//        [sidebarContentView addSubview:facebookAlbumButton];

        
//        twitterAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2*kWidthOfSidebarButton, buttonBounds.origin.y,
//                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        [twitterAlbumButton setImage:[UIImage imageNamed:@"twitter"]];
//        [sidebarContentView addSubview:twitterAlbumButton];


//        evernoteAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4*kWidthOfSidebarButton, buttonBounds.origin.y,
//                                                                                  kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        [evernoteAlbumButton setImage:[UIImage imageNamed:@"evernote"]];
//        [sidebarContentView addSubview:evernoteAlbumButton];
        
}
    return self;
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
    if(!pdfListContentView.hidden){
        [pdfListContentView show:animated];
    }
}

-(void) hide:(BOOL)animated{
    [super hide:animated];
    [[NSThread mainThread] performBlock:^{
        [cameraListContentView hide:animated];
        [albumListContentView hide:animated];
        [faceListContentView hide:animated];
        [eventListContentView hide:animated];
        [pdfListContentView hide:animated];
    } afterDelay:.1];
}

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView{
    [self.delegate pictureTakeWithCamera:img fromView:cameraView];
}

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(MMAbstractSidebarContentView *)container{
    [self.delegate photoWasTapped:asset fromView:bufferedImage withRotation:rotation fromContainer:[container description]];
}

-(void) switchToListView:(MMAbstractSidebarContentView*)listView{
    for(MMAbstractSidebarContentView* aListView in allListContentViews){
        if(aListView == listView){
            listView.hidden = NO;
            [listView show:NO];
        }else if(!aListView.hidden){
            [aListView hide:NO];
            aListView.hidden = YES;
        }
    }
}

-(void) cameraButtonTapped:(UIButton*)button{
    [self switchToListView:cameraListContentView];
}

-(void) albumButtonTapped:(UIButton*)button{
    [self switchToListView:albumListContentView];
}

-(void) faceButtonTapped:(UIButton*)button{
    [self switchToListView:faceListContentView];
}

-(void) eventButtonTapped:(UIButton*)button{
    [self switchToListView:eventListContentView];
}

-(void) pdfButtonTapped:(UIButton*)button{
    [self switchToListView:pdfListContentView];
}

#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums;{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cameraListContentView doneLoadingPhotoAlbums];
        [albumListContentView doneLoadingPhotoAlbums];
        [faceListContentView doneLoadingPhotoAlbums];
        [eventListContentView doneLoadingPhotoAlbums];
    });
}

-(void) albumUpdated:(MMPhotoAlbum*)updatedAlbum{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cameraListContentView albumUpdated:updatedAlbum];
        [albumListContentView albumUpdated:updatedAlbum];
        [faceListContentView albumUpdated:updatedAlbum];
        [eventListContentView albumUpdated:updatedAlbum];
    });
}

#pragma mark - Rotation

-(void) updatePhotoRotation{
    if(![self isVisible]) return;
    if(!cameraListContentView.hidden){
        [cameraListContentView updatePhotoRotation:YES];
    }else if(!albumListContentView.hidden){
        [albumListContentView updatePhotoRotation:YES];
    }else if(!faceListContentView.hidden){
        [faceListContentView updatePhotoRotation:YES];
    }else if(!eventListContentView.hidden){
        [eventListContentView updatePhotoRotation:YES];
    }else if(!pdfListContentView.hidden){
        [pdfListContentView updatePhotoRotation:YES];
    }
}

@end
