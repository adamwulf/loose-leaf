//
//  MMCameraCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraCollectionViewCell.h"
#import "MMBorderedCamView.h"
#import "MMFlipCameraButton.h"
#import "CaptureSessionManager.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "UIScreen+PortraitBounds.h"

@implementation MMCameraCollectionViewCell{
    CGFloat rowHeight;
    MMBorderedCamView* cameraRow;
    MMFlipCameraButton* flipButton;
}

@synthesize delegate;

-(CGRect) cameraViewFr{
    CGFloat ratio = [UIScreen mainScreen].portraitBounds.size.width / [UIScreen mainScreen].portraitBounds.size.height;
    CGRect cameraViewFr = CGRectZero;
    cameraViewFr.size.width = ratio * (rowHeight - kCameraMargin) * 2;
    cameraViewFr.size.height = (rowHeight - kCameraMargin) * 2;
    return cameraViewFr;
}


-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        AVCaptureDevicePosition preferredPosition = [[NSUserDefaults standardUserDefaults] integerForKey:kCameraPositionUserDefaultKey];
        rowHeight = ceilf(self.bounds.size.width / 2);
        CGRect cameraViewFr = [self cameraViewFr];
        
        cameraRow = [[MMBorderedCamView alloc] initWithFrame:cameraViewFr andCameraPosition:preferredPosition];
        cameraRow.delegate = self;
        cameraRow.rotation = RandomPhotoRotation(0)/2;
        cameraRow.center = CGPointMake((self.frame.size.width-kWidthOfSidebarButton)/2, kCameraMargin + cameraRow.bounds.size.height/2);

        flipButton = [[MMFlipCameraButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kWidthOfSidebarButton - kWidthOfSidebarButtonBuffer,
                                                                          floorf((cameraViewFr.size.height - kWidthOfSidebarButton) / 2),
                                                                          kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [flipButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:cameraRow];
        [self addSubview:flipButton];
        [self updatePhotoRotation:NO];
    }
    return self;
}

#pragma mark - Camera Button

-(void) changeCamera{
    [cameraRow changeCamera];
}

#pragma mark - MMCamViewDelegate

-(void) didTakePicture:(UIImage*)img{
    DebugLog(@"took picture!");
    [self.delegate pictureTakeWithCamera:img fromView:cameraRow];
}

-(void) didChangeCameraTo:(AVCaptureDevicePosition)preferredPosition{
    [[NSUserDefaults standardUserDefaults] setInteger:preferredPosition forKey:kCameraPositionUserDefaultKey];
}

-(void) sessionStarted{
    // noop
}

#pragma mark - Rotation

-(void) updatePhotoRotation:(BOOL)animated{
    [flipButton updatePhotoRotation:animated];
}

@end
