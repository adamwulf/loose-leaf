//
//  MMShareStackSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/10/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMShareStackSidebarContainerView.h"
#import "MMImageViewButton.h"
#import "MMEmailShareItem.h"
#import "MMTextShareItem.h"
#import "MMTwitterShareItem.h"
#import "MMFacebookShareItem.h"
#import "MMSinaWeiboShareItem.h"
#import "MMTencentWeiboShareItem.h"
#import "MMPhotoAlbumShareItem.h"
#import "MMImgurShareItem.h"
#import "MMPrintShareItem.h"
#import "MMOpenInAppShareItem.h"
#import "MMCopyShareItem.h"
#import "MMPinterestShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import "MMLargeTutorialSidebarButton.h"
#import "MMTutorialManager.h"
#import "UIImage+MMColor.h"
#import "NSString+URLEncode.h"
#import <JotUI/JotUI.h>


@implementation MMShareStackSidebarContainerView {
    UIView* sharingContentView;
    UIView* buttonView;
    NSMutableArray<MMAbstractShareItem*>* shareItems;

    MMLargeTutorialSidebarButton* tutorialButton;

    BOOL exportedPDF;

    NSURL* _pdfURLToShare;

    UIView* exportingView;
    UILabel* exportingLabel;
}

@synthesize shareDelegate;

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    if (self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft]) {
        // Initialization code
        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];

        CGRect contentBounds = [slidingSidebarView contentBounds];
        CGRect buttonBounds = scrollViewBounds;
        buttonBounds.origin.y = 0;
        buttonBounds.size.height = 10;
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        buttonView = [[UIView alloc] initWithFrame:contentBounds];
        [sharingContentView addSubview:buttonView];
        [slidingSidebarView addSubview:sharingContentView];

        CGRect exportViewFrame = CGRectSquare(CGRectGetWidth([slidingSidebarView contentBounds]));
        exportViewFrame.origin.x = CGRectGetWidth(exportViewFrame) / 5;
        exportingView = [[UIView alloc] initWithFrame:exportViewFrame];

        exportingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(exportViewFrame), 100)];
        [exportingLabel setNumberOfLines:2];
        [exportingLabel setTextColor:[UIColor whiteColor]];
        [exportingLabel setFont:[UIFont systemFontOfSize:24]];
        [exportingLabel setTextAlignment:NSTextAlignmentCenter];
        [exportingLabel setText:NSLocalizedString(@"Exporting all pages...", @"Exporting all pages...")];
        [exportingView addSubview:exportingLabel];


        UIButton* cancelExportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(exportViewFrame) * 4 / 5, 50)];
        [cancelExportButton addTarget:self action:@selector(cancelStackExport:) forControlEvents:UIControlEventTouchUpInside];
        [cancelExportButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        [cancelExportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelExportButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1 alpha:.5]] forState:UIControlStateNormal];
        [cancelExportButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1 alpha:.7]] forState:UIControlStateHighlighted];
        [cancelExportButton setClipsToBounds:YES];
        [[cancelExportButton layer] setBorderColor:[[UIColor colorWithWhite:0 alpha:.6] CGColor]];
        [[cancelExportButton layer] setBorderWidth:2];
        [[cancelExportButton layer] setCornerRadius:8];

        [exportingView addSubview:cancelExportButton];

        CGFloat midpoint = CGRectGetWidth(exportViewFrame) / 2;
        cancelExportButton.center = CGPointMake(midpoint, midpoint + 20);

        [sharingContentView addSubview:exportingView];

        //////////////////////////////////////////
        // buttons
        shareItems = [NSMutableArray array];
        [shareItems addObject:[[MMEmailShareItem alloc] init]];
        [shareItems addObject:[[MMTextShareItem alloc] init]];
        [shareItems addObject:[[MMPhotoAlbumShareItem alloc] init]];
        [shareItems addObject:[[MMSinaWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTencentWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTwitterShareItem alloc] init]];
        [shareItems addObject:[[MMFacebookShareItem alloc] init]];
        [shareItems addObject:[[MMPinterestShareItem alloc] init]];
        [shareItems addObject:[[MMImgurShareItem alloc] init]];
        [shareItems addObject:[[MMPrintShareItem alloc] init]];
        [shareItems addObject:[[MMCopyShareItem alloc] init]];
        [shareItems addObject:[[MMOpenInAppShareItem alloc] init]];

        [self updateShareOptions];

        tutorialButton = [[MMLargeTutorialSidebarButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton) andTutorialList:^NSArray* {
            return [[MMTutorialManager sharedInstance] shareTutorialSteps];
        }];
        tutorialButton.center = CGPointMake(sharingContentView.bounds.size.width / 2, sharingContentView.bounds.size.height - 100);
        [tutorialButton addTarget:self action:@selector(startWatchingExportTutorials) forControlEvents:UIControlEventTouchUpInside];
        [sharingContentView addSubview:tutorialButton];
    }
    return self;
}

- (void)cancelStackExport:(UIButton*)button {
    [self hide:YES onComplete:nil];
}

- (void)setExportType:(id)sender {
    CheckMainThread;

    exportingView.alpha = 1;
    buttonView.alpha = 0;

    [self updateShareOptions];

    exportedPDF = YES;

    [self.shareDelegate exportStackToPDF:^(NSURL* urlToPDF) {
        CheckMainThread;
        _pdfURLToShare = urlToPDF;
        dispatch_async(dispatch_get_main_queue(), ^{
            exportingView.alpha = 0;
            buttonView.alpha = 1;
            [self updateShareOptions];
        });
    } withProgress:^BOOL(NSInteger pageSoFar, NSInteger totalPages) {
        CheckMainThread;
        [exportingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Exporting all pages...\n %ld of %ld pages", @"Exporting all pages...\n %ld of %ld pages"), (long)pageSoFar, (long)totalPages]];
        // cancel the export if we're hidden
        return ![self isVisible];
    }];
}

- (NSURL*)urlToShare {
    return _pdfURLToShare;
}

- (NSString*)idealFileNameForShare {
    return [[[self shareDelegate] nameOfCurrentStack] stringByRemovingWhiteSpace];
}

- (NSString*)pathForOrientation:(UIImageOrientation)orientation givenURL:(NSURL*)url {
    NSString* fileNameForOrientation = [NSString stringWithFormat:@"%@%ld.png", [url lastPathComponent], (long)orientation];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileNameForOrientation];
}

- (void)startWatchingExportTutorials {
    [[MMTutorialManager sharedInstance] startWatchingTutorials:tutorialButton.tutorialList];
}

- (CGFloat)buttonWidth {
    CGFloat buttonWidth = buttonView.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
    buttonWidth /= 4; // four buttons wide
    return buttonWidth;
}

- (CGRect)buttonBounds {
    CGFloat buttonWidth = [self buttonWidth];
    CGRect buttonBounds = buttonView.bounds;
    buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
    buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
    buttonBounds.size.width -= 2 * kWidthOfSidebarButtonBuffer;
    return buttonBounds;
}

- (void)updateShareOptions {
    [NSThread performBlockOnMainThread:^{
        [buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        int buttonIndex = 0;
        CGFloat buttonWidth = [self buttonWidth];
        CGRect buttonBounds = [self buttonBounds];
        for (MMEmailShareItem* item in shareItems) {
            if ([item isAtAllPossibleForMimeType:[NSURL mimeForExtension:@"pdf"]]) {
                item.delegate = self;

                MMSidebarButton* button = item.button;
                int column = (buttonIndex % 4);
                int row = floor(buttonIndex / 4.0);
                button.frame = CGRectMake(buttonBounds.origin.x + column * (buttonWidth),
                                          buttonBounds.origin.y + row * (buttonWidth),
                                          buttonWidth, buttonWidth);

                [buttonView insertSubview:button atIndex:buttonIndex];

                [item updateButtonGreyscale];

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

- (void)show:(BOOL)animated {
    for (MMAbstractShareItem* shareItem in shareItems) {
        if ([shareItem respondsToSelector:@selector(willShow)]) {
            [shareItem willShow];
        }
    }
    // hide tutorial if we have an options view visible
    tutorialButton.hidden = NO;
    [super show:animated];

    [exportingLabel setText:NSLocalizedString(@"Exporting all pages...", @"Exporting all pages...")];

    [self setExportType:nil];
}


- (void)hide:(BOOL)animated onComplete:(void (^)(BOOL finished))onComplete {
    [super hide:animated onComplete:^(BOOL finished) {
        // notify any buttons that they're now hidden.
        for (MMAbstractShareItem* shareItem in shareItems) {
            if ([shareItem respondsToSelector:@selector(didHide)]) {
                [shareItem didHide];
            }
        }
        if (onComplete) {
            onComplete(finished);
        }

        exportedPDF = NO;
        _pdfURLToShare = nil;
    }];
}


- (MMAbstractShareItem*)closeActiveSharingOptionsForButton:(UIButton*)button {
    MMAbstractShareItem* shareItemForButton = nil;
    for (MMAbstractShareItem* shareItem in shareItems) {
        if (shareItem.button == button) {
            shareItemForButton = shareItem;
        }
        [shareItem setShowingOptionsView:NO];
    }
    return shareItemForButton;
}

#pragma mark - Rotation

- (CGFloat)sidebarButtonRotation {
    if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait) {
        return 0;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft) {
        return -M_PI_2;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight) {
        return M_PI_2;
    } else {
        return M_PI;
    }
}

- (void)updateInterfaceTo:(UIInterfaceOrientation)orientation {
    CheckMainThread;
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        for (MMBounceButton* button in [buttonView.subviews arrayByAddingObject:tutorialButton]) {
            button.rotation = [self sidebarButtonRotation];
            button.transform = rotationTransform;
        }

        exportingView.transform = rotationTransform;
    }];
}

#pragma mark - MMShareItemDelegate

- (void)mayShare:(MMAbstractShareItem*)shareItem {
    // close out all of our sharing options views,
    // if any
    [self closeActiveSharingOptionsForButton:nil];
    // now check if our new item has a sharing
    // options panel or not
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            tutorialButton.hidden = NO;
            [shareDelegate mayShare:shareItem];
        }
    });
}

// called when a may share is cancelled
- (void)wontShare:(MMAbstractShareItem*)shareItem {
    // close out all of our sharing options views,
    // if any
    [self closeActiveSharingOptionsForButton:nil];
    tutorialButton.hidden = NO;
}

- (void)didShare:(MMAbstractShareItem*)shareItem {
    [shareDelegate didShare:shareItem];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
