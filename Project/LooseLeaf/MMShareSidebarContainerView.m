//
//  MMShareSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareSidebarContainerView.h"
#import "MMImageViewButton.h"
#import "Constants.h"

@implementation MMShareSidebarContainerView{
    MMImageViewButton* facebookShareButton;
    MMImageViewButton* twitterShareButton;
    MMImageViewButton* evernoteShareButton;
    MMImageViewButton* emailShareButton;
}

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    if (self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft]) {
        // Initialization code
        CGRect contentBounds = [sidebarContentView contentBounds];
        
        CGFloat buttonWidth = contentBounds.size.width - 4*kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
        buttonWidth /= 4; // three buttons wide
        
        CGRect buttonBounds = contentBounds;
        buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
        buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
        
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        
        emailShareButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x,
                                                                               buttonBounds.origin.y, buttonWidth, buttonWidth)];
        [emailShareButton setImage:[UIImage imageNamed:@"email"]];
        [sidebarContentView addSubview:emailShareButton];

        facebookShareButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + (kWidthOfSidebarButtonBuffer + buttonWidth), buttonBounds.origin.y,
                                                                                 buttonWidth, buttonWidth)];
        [facebookShareButton setImage:[UIImage imageNamed:@"facebook"]];
        [sidebarContentView addSubview:facebookShareButton];


        twitterShareButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 2*(kWidthOfSidebarButtonBuffer + buttonWidth),
                                                                                 buttonBounds.origin.y, buttonWidth, buttonWidth)];
        [twitterShareButton setImage:[UIImage imageNamed:@"twitter"]];
        [sidebarContentView addSubview:twitterShareButton];


        evernoteShareButton = [[MMImageViewButton alloc] initWithFrame:CGRectMake(buttonBounds.origin.x + 3*(kWidthOfSidebarButtonBuffer + buttonWidth),
                                                                                  buttonBounds.origin.y, buttonWidth, buttonWidth)];
        [evernoteShareButton setImage:[UIImage imageNamed:@"evernote"]];
        [sidebarContentView addSubview:evernoteShareButton];
        
        
        emailShareButton.greyscale = YES;
    }
    return self;
}

#pragma mark - Rotation

-(void) updatePhotoRotation{
    if(![self isVisible]) return;
//    if(!cameraListContentView.hidden){
//        [cameraListContentView updatePhotoRotation:YES];
//    }else if(!albumListContentView.hidden){
//        [albumListContentView updatePhotoRotation:YES];
//    }else if(!faceListContentView.hidden){
//        [faceListContentView updatePhotoRotation:YES];
//    }else if(!eventListContentView.hidden){
//        [eventListContentView updatePhotoRotation:YES];
//    }else if(!pdfListContentView.hidden){
//        [pdfListContentView updatePhotoRotation:YES];
//    }
}

@end
