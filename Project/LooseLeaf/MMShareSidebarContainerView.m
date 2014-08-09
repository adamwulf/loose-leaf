//
//  MMShareSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareSidebarContainerView.h"
#import "MMImageViewButton.h"
#import "MMEmailShareItem.h"
#import "MMTextShareItem.h"
#import "MMTwitterShareItem.h"
#import "MMFacebookShareItem.h"
#import "MMSinaWeiboShareItem.h"
#import "MMTencentWeiboShareItem.h"
#import "MMPhotoAlbumShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMShareSidebarContainerView{
    UIView* buttonView;
    NSMutableArray* shareItems;
}

@synthesize shareDelegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    if (self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft]) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShareOptions)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        buttonView = [[UIView alloc] initWithFrame:[sidebarContentView contentBounds]];
        [sidebarContentView addSubview:buttonView];

        [self updateShareOptions];
        
    }
    return self;
}

-(void) updateShareOptions{
    [NSThread performBlockOnMainThread:^{
        [buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGRect contentBounds = [sidebarContentView contentBounds];
        
        CGFloat buttonWidth = buttonView.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
        buttonWidth /= 4; // four buttons wide
        
        CGRect buttonBounds = buttonView.bounds;
        buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
        buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
        
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        
        shareItems = [NSMutableArray array];
        
        [shareItems addObject:[[MMEmailShareItem alloc] init]];
        [shareItems addObject:[[MMTextShareItem alloc] init]];
        [shareItems addObject:[[MMSinaWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTencentWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTwitterShareItem alloc] init]];
        [shareItems addObject:[[MMFacebookShareItem alloc] init]];
        [shareItems addObject:[[MMPhotoAlbumShareItem alloc] init]];
        
        int buttonIndex = 0;
        for(MMEmailShareItem* item in shareItems){
            if(item.isAtAllPossible){
                item.delegate = self;
                
                MMSidebarButton* button = item.button;
                int column = (buttonIndex%4);
                int row = floor(buttonIndex / 4.0);
                button.frame = CGRectMake(buttonBounds.origin.x + column*(buttonWidth),
                                          buttonBounds.origin.y + row*(buttonWidth),
                                          buttonWidth, buttonWidth);
                [buttonView addSubview:button];
                
                buttonIndex += 1;
            }
        }
    }];
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

#pragma mark - MMShareItemDelegate

-(UIImage*) imageToShare{
    return shareDelegate.imageToShare;
}

-(void) didShare{
    [shareDelegate didShare];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
