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
#import "MMPrintShareItem.h"
#import "MMOpenInAppShareItem.h"
#import "MMCopyShareItem.h"
#import "MMPinterestShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "MMShareOptionsView.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import <JotUI/JotUI.h>


@interface MMShareSidebarContainerView ()

@property (nonatomic, strong) NSURL* imageURLToShare;
@property (nonatomic, strong) NSURL* pdfURLToShare;

@end


@implementation MMShareSidebarContainerView {
    UIView* sharingContentView;
    UIView* buttonView;
    MMShareOptionsView* activeOptionsView;
    NSMutableArray<MMAbstractShareItem*>* shareItems;

    UIButton* exportAsImageButton;
    UIButton* exportAsPDFButton;

    UIButton* landscapeLeftButton;
    UIButton* portraitButton;
    UIButton* landscapeRightButton;

    BOOL exportedImage;
    BOOL exportedPDF;
}

@synthesize shareDelegate;

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    if (self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft]) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShareOptions)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];

        CGRect contentBounds = [slidingSidebarView contentBounds];
        CGRect buttonBounds = scrollViewBounds;
        buttonBounds.origin.y = 0;
        buttonBounds.size.height = kHeightOfImportTypeButton + kHeightOfRotationTypeButton + 10;
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;
        buttonView = [[UIView alloc] initWithFrame:contentBounds];
        [sharingContentView addSubview:buttonView];
        [slidingSidebarView addSubview:sharingContentView];

        //////////////////////////////////////////
        // export type buttons


        exportAsImageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(buttonBounds) + (CGRectGetWidth(buttonBounds) - 2 * kHeightOfImportTypeButton - 10) / 2, 10, kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [exportAsImageButton setBackgroundImage:[UIImage imageNamed:@"exportAsImage"] forState:UIControlStateNormal];
        [exportAsImageButton setBackgroundImage:[UIImage imageNamed:@"exportAsImageHighlighted"] forState:UIControlStateSelected];
        [exportAsImageButton setAdjustsImageWhenHighlighted:NO];
        [exportAsImageButton addTarget:self action:@selector(setExportType:) forControlEvents:UIControlEventTouchUpInside];
        exportAsImageButton.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:kExportAsPDFPreferenceDefault];
        [slidingSidebarView addSubview:exportAsImageButton];

        exportAsPDFButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(buttonBounds) + (CGRectGetWidth(buttonBounds) - 2 * kHeightOfImportTypeButton - 10) / 2 + 10 + kHeightOfImportTypeButton, 10, kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [exportAsPDFButton setBackgroundImage:[UIImage imageNamed:@"exportAsPDF"] forState:UIControlStateNormal];
        [exportAsPDFButton setBackgroundImage:[UIImage imageNamed:@"exportAsPDFHighlighted"] forState:UIControlStateSelected];
        [exportAsPDFButton setAdjustsImageWhenHighlighted:NO];
        [exportAsPDFButton addTarget:self action:@selector(setExportType:) forControlEvents:UIControlEventTouchUpInside];
        exportAsPDFButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:kExportAsPDFPreferenceDefault];
        [slidingSidebarView addSubview:exportAsPDFButton];

        //////////////////////////////////////////
        // rotation buttons

        landscapeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(buttonBounds) + (CGRectGetWidth(buttonBounds) - 2 * kHeightOfImportTypeButton - 10) / 2, 10 + kHeightOfImportTypeButton + 10, kHeightOfRotationTypeButton, kHeightOfRotationTypeButton)];
        [landscapeLeftButton setBackgroundImage:[UIImage imageNamed:@"landscapeLeftOrientation"] forState:UIControlStateNormal];
        [landscapeLeftButton setBackgroundImage:[UIImage imageNamed:@"landscapeLeftOrientationHighlighted"] forState:UIControlStateSelected];
        [landscapeLeftButton setAdjustsImageWhenHighlighted:NO];
        [landscapeLeftButton addTarget:self action:@selector(rotateLandscapeLeft:) forControlEvents:UIControlEventTouchUpInside];
        [slidingSidebarView addSubview:landscapeLeftButton];

        portraitButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(buttonBounds) - kHeightOfRotationTypeButton / 2, 10 + kHeightOfImportTypeButton + 10, kHeightOfRotationTypeButton, kHeightOfRotationTypeButton)];
        [portraitButton setBackgroundImage:[UIImage imageNamed:@"portraitOrientation"] forState:UIControlStateNormal];
        [portraitButton setBackgroundImage:[UIImage imageNamed:@"portraitOrientationHighlighted"] forState:UIControlStateSelected];
        [portraitButton setAdjustsImageWhenHighlighted:NO];
        [portraitButton addTarget:self action:@selector(rotatePortrait:) forControlEvents:UIControlEventTouchUpInside];
        //        portraitButton = [[NSUserDefaults standardUserDefaults] boolForKey:kExportAsPDFPreferenceDefault];
        [slidingSidebarView addSubview:portraitButton];

        landscapeRightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(buttonBounds) + (CGRectGetWidth(buttonBounds) - 2 * kHeightOfRotationTypeButton - 10) / 2 + 10 + kHeightOfImportTypeButton, 10 + kHeightOfImportTypeButton + 10, kHeightOfRotationTypeButton, kHeightOfRotationTypeButton)];
        [landscapeRightButton setBackgroundImage:[UIImage imageNamed:@"landscapeRightOrientation"] forState:UIControlStateNormal];
        [landscapeRightButton setBackgroundImage:[UIImage imageNamed:@"landscapeRightOrientationHighlighted"] forState:UIControlStateSelected];
        [landscapeRightButton setAdjustsImageWhenHighlighted:NO];
        [landscapeRightButton addTarget:self action:@selector(rotateLandscapeRight:) forControlEvents:UIControlEventTouchUpInside];
        //        landscapeRightButton = [[NSUserDefaults standardUserDefaults] boolForKey:kExportAsPDFPreferenceDefault];
        [slidingSidebarView addSubview:landscapeRightButton];

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
    }
    return self;
}

- (void)setRotationType:(ExportRotation)rotation {
    [landscapeLeftButton setSelected:rotation == ExportRotationLandscapeLeft];
    [portraitButton setSelected:rotation == ExportRotationPortrait];
    [landscapeRightButton setSelected:rotation == ExportRotationLandscapeRight];
}

- (void)rotateLandscapeLeft:(id)sender {
    if ([[self shareDelegate] idealExportRotation] != ExportRotationLandscapeLeft) {
        exportedImage = NO;
        exportedPDF = NO;
        _pdfURLToShare = nil;
        _imageURLToShare = nil;
        [[self shareDelegate] setIdealExportRotation:ExportRotationLandscapeLeft];
        [self setRotationType:ExportRotationLandscapeLeft];
    }
    [self reExportImageOrPDFIfNeeded];
}

- (void)rotatePortrait:(id)sender {
    if ([[self shareDelegate] idealExportRotation] != ExportRotationPortrait) {
        exportedImage = NO;
        exportedPDF = NO;
        _pdfURLToShare = nil;
        _imageURLToShare = nil;
        [[self shareDelegate] setIdealExportRotation:ExportRotationPortrait];
        [self setRotationType:ExportRotationPortrait];
    }
    [self reExportImageOrPDFIfNeeded];
}

- (void)rotateLandscapeRight:(id)sender {
    if ([[self shareDelegate] idealExportRotation] != ExportRotationLandscapeRight) {
        exportedImage = NO;
        exportedPDF = NO;
        _pdfURLToShare = nil;
        _imageURLToShare = nil;
        [[self shareDelegate] setIdealExportRotation:ExportRotationLandscapeRight];
        [self setRotationType:ExportRotationLandscapeRight];
    }
    [self reExportImageOrPDFIfNeeded];
}


- (void)setExportType:(id)sender {
    CheckMainThread;
    exportAsImageButton.selected = (exportAsImageButton == sender);
    exportAsPDFButton.selected = (exportAsPDFButton == sender);

    [[NSUserDefaults standardUserDefaults] setBool:exportAsPDFButton.selected forKey:kExportAsPDFPreferenceDefault];

    [self reExportImageOrPDFIfNeeded];
}

- (void)reExportImageOrPDFIfNeeded {
    [self updateShareOptions];

    if (exportAsImageButton.selected && !exportedImage) {
        exportedImage = YES;
        [self.shareDelegate exportVisiblePageToImage:^(NSURL* urlToShare) {
            _imageURLToShare = urlToShare;

            // clear our rotated image cache
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForOrientation:UIImageOrientationRight givenURL:_imageURLToShare] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForOrientation:UIImageOrientationLeft givenURL:_imageURLToShare] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForOrientation:UIImageOrientationDown givenURL:_imageURLToShare] error:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateShareOptions];
            });
        }];

        [self updateShareOptions];
    }

    if (exportAsPDFButton.selected && !exportedPDF) {
        exportedPDF = YES;

        [self.shareDelegate exportVisiblePageToPDF:^(NSURL* urlToShare) {
            _pdfURLToShare = urlToShare;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateShareOptions];
            });
        }];
    }
}

- (NSString*)idealFileNameForShare {
    return @"LooseLeaf";
}

- (NSURL*)urlToShare {
    if (exportAsImageButton.selected) {
        return _imageURLToShare;
    } else {
        return _pdfURLToShare;
    }
}

- (NSString*)pathForOrientation:(UIImageOrientation)orientation givenURL:(NSURL*)url {
    NSString* fileNameForOrientation = [NSString stringWithFormat:@"%@%ld.png", [url lastPathComponent], (long)orientation];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileNameForOrientation];
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
    buttonBounds.origin.x += 2 * kWidthOfSidebarButtonBuffer;
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
            if ([item isAtAllPossibleForMimeType:[NSURL mimeForExtension:exportAsImageButton.selected ? @"png" : @"pdf"]]) {
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
    [activeOptionsView reset];
    [activeOptionsView show];
    [super show:animated];

    [self setExportType:[[NSUserDefaults standardUserDefaults] boolForKey:kExportAsPDFPreferenceDefault] ? exportAsPDFButton : exportAsImageButton];
    [self setRotationType:[[self shareDelegate] idealExportRotation]];
}


- (void)hide:(BOOL)animated onComplete:(void (^)(BOOL finished))onComplete {
    [super hide:animated onComplete:^(BOOL finished) {
        [activeOptionsView hide];
        if (activeOptionsView.shouldCloseWhenSidebarHides) {
            [self closeActiveSharingOptionsForButton:nil];
            while ([sharingContentView.subviews count] > 1) {
                // remove any options views
                [[sharingContentView.subviews objectAtIndex:1] removeFromSuperview];
            }
        }
        // notify any buttons that they're now hidden.
        for (MMAbstractShareItem* shareItem in shareItems) {
            if ([shareItem respondsToSelector:@selector(didHide)]) {
                [shareItem didHide];
            }
        }
        if (onComplete) {
            onComplete(finished);
        }

        exportedImage = NO;
        exportedPDF = NO;
        _pdfURLToShare = nil;
        _imageURLToShare = nil;
    }];
}


- (MMAbstractShareItem*)closeActiveSharingOptionsForButton:(UIButton*)button {
    if (activeOptionsView) {
        [activeOptionsView removeFromSuperview];
        [activeOptionsView reset];
        activeOptionsView = nil;
    }
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
    [activeOptionsView updateInterfaceTo:orientation];
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        for (MMBounceButton* button in buttonView.subviews) {
            button.rotation = [self sidebarButtonRotation];
            button.transform = rotationTransform;
        }

        exportAsImageButton.transform = rotationTransform;
        exportAsPDFButton.transform = rotationTransform;
    }];
}

#pragma mark - MMShareItemDelegate

- (void)exportVisiblePageToImage:(void (^)(NSURL* urlToImage))completionBlock {
    [shareDelegate exportVisiblePageToImage:completionBlock];
}

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    [shareDelegate exportVisiblePageToPDF:completionBlock];
}

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
            activeOptionsView = [shareItem optionsView];
            if (activeOptionsView) {
                [activeOptionsView reset];
                CGRect frForOptions = buttonView.frame;
                frForOptions.origin.y = CGRectGetMaxY([buttonView frame]);
                frForOptions.size.height = sharingContentView.bounds.size.height - CGRectGetMaxY([buttonView frame]);
                activeOptionsView.frame = frForOptions;
                [shareItem setShowingOptionsView:YES];
                [sharingContentView addSubview:activeOptionsView];
            }

            [shareDelegate mayShare:shareItem];
        }
    });
}

// called when a may share is cancelled
- (void)wontShare:(MMAbstractShareItem*)shareItem {
    // close out all of our sharing options views,
    // if any
    [self closeActiveSharingOptionsForButton:nil];
    activeOptionsView = nil;
}

- (void)didShare:(MMAbstractShareItem*)shareItem {
    [shareDelegate didShare:shareItem];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
