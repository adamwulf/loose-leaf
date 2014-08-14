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
#import "MMImgurShareItem.h"
#import "MMOpenInShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "MMShareManager.h"
#import "Constants.h"
#import "UIView+Debug.h"

@implementation MMShareSidebarContainerView{
    UIScrollView* scrollView;
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
        
        scrollView = [[UIScrollView alloc] initWithFrame:[sidebarContentView contentBounds]];
        scrollView.bounces = YES;
        scrollView.alwaysBounceVertical = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        buttonView = [[UIView alloc] initWithFrame:scrollView.bounds];
        [scrollView addSubview:buttonView];
        [sidebarContentView addSubview:scrollView];
        scrollView.contentSize = scrollView.bounds.size;
        
        
        shareItems = [NSMutableArray array];
        [shareItems addObject:[[MMEmailShareItem alloc] init]];
        [shareItems addObject:[[MMTextShareItem alloc] init]];
        [shareItems addObject:[[MMPhotoAlbumShareItem alloc] init]];
        [shareItems addObject:[[MMSinaWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTencentWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTwitterShareItem alloc] init]];
        [shareItems addObject:[[MMFacebookShareItem alloc] init]];
        [shareItems addObject:[[MMImgurShareItem alloc] init]];
        [shareItems addObject:[[MMOpenInShareItem alloc] init]];

        for (NSObject<MMShareItem>*shareItem in shareItems) {
            [shareItem.button addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self updateShareOptions];
        
    }
    return self;
}

-(CGFloat) buttonWidth{
    CGFloat buttonWidth = buttonView.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
    buttonWidth /= 4; // four buttons wide
    return buttonWidth;
}

-(CGRect) buttonBounds{
    CGFloat buttonWidth = [self buttonWidth];
    CGRect buttonBounds = buttonView.bounds;
    buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
    buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
    return buttonBounds;
}

-(void) updateShareOptions{
    [NSThread performBlockOnMainThread:^{
        [buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        int buttonIndex = 0;
        CGFloat buttonWidth = [self buttonWidth];
        CGRect buttonBounds = [self buttonBounds];
        for(MMEmailShareItem* item in shareItems){
            if(item.isAtAllPossible){
                item.delegate = self;
                
                MMSidebarButton* button = item.button;
                int column = (buttonIndex%4);
                int row = floor(buttonIndex / 4.0);
                button.frame = CGRectMake(buttonBounds.origin.x + column*(buttonWidth),
                                          buttonBounds.origin.y + row*(buttonWidth),
                                          buttonWidth, buttonWidth);
                [buttonView insertSubview:button atIndex:buttonIndex];
                
                buttonIndex += 1;
            }
        }
        
        UIView* lastButton = [buttonView.subviews lastObject];
        CGRect fr = buttonView.frame;
        fr.size.height = lastButton.frame.origin.y + lastButton.frame.size.height + kWidthOfSidebarButtonBuffer;
        buttonView.frame = fr;
    }];
}

#pragma mark - Sharing button tapped

-(void) shareButtonTapped:(MMSidebarButton*)button{
    NSObject<MMShareItem>*shareItemForButton = nil;
    for (NSObject<MMShareItem>*shareItem in shareItems) {
        if(shareItem.button == button){
            shareItemForButton = shareItem;
            break;
        }
    }

    // now we have the share item
    if([shareItemForButton respondsToSelector:@selector(optionsView)]){
        button.selected = YES;
        [button setNeedsDisplay];
        UIView* optionsView = [shareItemForButton optionsView];
        CGRect frForOptions = buttonView.bounds;
        frForOptions.origin.y = buttonView.bounds.size.height;
        frForOptions.size.height = kWidthOfSidebarButtonBuffer;
        optionsView.frame = frForOptions;
        [scrollView addSubview:optionsView];
        
        scrollView.contentSize = CGSizeMake(optionsView.bounds.size.width, optionsView.bounds.size.height + buttonView.bounds.size.height);
    }
}

-(void) show:(BOOL)animated{
    for (NSObject<MMShareItem>*shareItem in shareItems) {
        if([shareItem respondsToSelector:@selector(willShow)]){
            [shareItem willShow];
        }
    }
    [super show:animated];
}

-(void) hide:(BOOL)animated onComplete:(void(^)(BOOL finished))onComplete{
    [super hide:animated onComplete:^(BOOL finished){
        while([scrollView.subviews count] > 1){
            // remove any options views
            [[scrollView.subviews objectAtIndex:1] removeFromSuperview];
            [scrollView setContentOffset:CGPointZero animated:NO];
        }
        // notify any buttons that they're now hidden.
        for (NSObject<MMShareItem>*shareItem in shareItems) {
            if([shareItem respondsToSelector:@selector(didHide)]){
                [shareItem didHide];
            }
        }
    }];
}

#pragma mark - Rotation

-(void) updatePhotoRotation{
    if(![self isVisible]) return;
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
