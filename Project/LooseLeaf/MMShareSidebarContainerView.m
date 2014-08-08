//
//  MMShareSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareSidebarContainerView.h"

@implementation MMShareSidebarContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
