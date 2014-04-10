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
#import "MMPhotoManager.h"
#import "MMImageViewButton.h"
#import "MMFaceButton.h"
#import "MMPalmTreeButton.h"
#import "Constants.h"

@implementation MMImageSidebarContainerView{
    MMAbstractSidebarContentView* albumListContentView;
    MMAbstractSidebarContentView* faceListContentView;
    
    MMImageViewButton* photoAlbumButton;
    MMImageViewButton* cameraAlbumButton;
    MMImageViewButton* twitterAlbumButton;
    MMImageViewButton* facebookAlbumButton;
    MMImageViewButton* evernoteAlbumButton;
    MMFaceButton* faceButton;
    MMPalmTreeButton* palmTreeButton;
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
        albumListContentView = [[MMAlbumSidebarContentView alloc] initWithFrame:contentBounds];
        albumListContentView.delegate = self;
        [sidebarContentView addSubview:albumListContentView];
        
        faceListContentView = [[MMFaceSidebarContentView alloc] initWithFrame:contentBounds];
        faceListContentView.delegate = self;
        [sidebarContentView addSubview:faceListContentView];
        faceListContentView.hidden = YES;
        
        cameraAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        cameraAlbumButton.darkBg = YES;
        [cameraAlbumButton setImage:[UIImage imageNamed:@"clearcamera"]];
        [sidebarContentView addSubview:cameraAlbumButton];

        photoAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [photoAlbumButton setImage:[UIImage imageNamed:@"clearphotoalbum"]];
        [photoAlbumButton addTarget:self action:@selector(albumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:photoAlbumButton];
        
        faceButton = [[MMFaceButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                               kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [faceButton addTarget:self action:@selector(faceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebarContentView addSubview:faceButton];
        
        palmTreeButton = [[MMPalmTreeButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 3* kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                    kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [sidebarContentView addSubview:palmTreeButton];
        
        
        
//        twitterAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2*kWidthOfSidebarButton, buttonBounds.origin.y,
//                                                                                kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        [twitterAlbumButton setImage:[UIImage imageNamed:@"twitter"]];
//        [sidebarContentView addSubview:twitterAlbumButton];
        
        facebookAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4*kWidthOfSidebarButton, buttonBounds.origin.y,
                                                                                 kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [facebookAlbumButton setImage:[UIImage imageNamed:@"facebook"]];
        [sidebarContentView addSubview:facebookAlbumButton];
        
//        evernoteAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 4*kWidthOfSidebarButton, buttonBounds.origin.y,
//                                                                                  kWidthOfSidebarButton, kWidthOfSidebarButton)];
//        [evernoteAlbumButton setImage:[UIImage imageNamed:@"evernote"]];
//        [sidebarContentView addSubview:evernoteAlbumButton];
        
}
    return self;
}

-(void) show:(BOOL)animated{
    [super show:animated];
    [self albumButtonTapped:nil];
}

-(void) hide:(BOOL)animated{
    [super hide:animated];
    albumListContentView.hidden = NO;
    faceListContentView.hidden = YES;
    [albumListContentView hide:animated];
    [faceListContentView hide:animated];
}

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage{
    [self.delegate photoWasTapped:asset fromView:bufferedImage];
}


-(void) albumButtonTapped:(UIButton*)button{
    albumListContentView.hidden = NO;
    faceListContentView.hidden = YES;
    [albumListContentView show:NO];
    [faceListContentView hide:NO];
}

-(void) faceButtonTapped:(UIButton*)button{
    albumListContentView.hidden = YES;
    faceListContentView.hidden = NO;
    [albumListContentView hide:NO];
    [faceListContentView show:NO];
}


#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums;{
    [albumListContentView doneLoadingPhotoAlbums];
    [faceListContentView doneLoadingPhotoAlbums];
}

-(void) albumUpdated:(MMPhotoAlbum*)updatedAlbum{
    [albumListContentView albumUpdated:updatedAlbum];
    [faceListContentView albumUpdated:updatedAlbum];
}

@end
