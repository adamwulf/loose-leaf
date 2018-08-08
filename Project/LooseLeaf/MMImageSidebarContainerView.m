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
#import "MMShapeSidebarContentView.h"
#import "MMEmojiSidebarContentView.h"
#import "MMInboxContentView.h"
#import "MMButtonBoxView.h"
#import "MMPhotoManager.h"
#import "MMImageViewButton.h"
#import "MMFaceButton.h"
#import "MMPalmTreeButton.h"
#import "MMInboxButton.h"
#import "MMShapesButton.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "MMCameraButton.h"
#import "NSThread+BlockAdditions.h"
#import "UIImage+MMColor.h"
#import <JotUI/JotUI.h>


@implementation MMImageSidebarContainerView {
    MMCameraSidebarContentView* cameraListContentView;
    MMAlbumSidebarContentView* albumListContentView;
    MMFaceSidebarContentView* faceListContentView;
    MMEventSidebarContentView* eventListContentView;
    MMInboxContentView* inboxListContentView;
    MMShapeSidebarContentView* shapeContentView;
    MMEmojiSidebarContentView* emojiContentView;

    NSArray* allListContentViews;

    MMCameraButton* cameraAlbumButton;
    MMImageViewButton* iPhotoAlbumButton;
    MMFaceButton* iPhotoFacesButton;
    MMPalmTreeButton* iPhotoEventsButton;
    MMInboxButton* inboxButton;
    MMShapesButton* shapeButton;
    MMShapesButton* emojiButton;

    UIButton* importAsPageButton;
    UIButton* importAsScrapButton;
}

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft];
    if (self) {
        CGRect contentBounds = [slidingSidebarView contentBounds];

        [MMPhotoManager sharedInstance].delegate = self;

        //////////////////////////////////////////
        // buttons

        importAsPageButton = [[UIButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kHeightOfImportTypeButton, kHeightOfImportTypeButton))];
        [importAsPageButton setBackgroundImage:[UIImage imageNamed:@"importAsPage"] forState:UIControlStateNormal];
        [importAsPageButton setBackgroundImage:[UIImage imageNamed:@"importAsPageHighlighted"] forState:UIControlStateSelected];
        [importAsPageButton addTarget:self action:@selector(setImportType:) forControlEvents:UIControlEventTouchUpInside];
        importAsPageButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:kImportAsPagePreferenceDefault];

        importAsScrapButton = [[UIButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kHeightOfImportTypeButton, kHeightOfImportTypeButton))];
        [importAsScrapButton setBackgroundImage:[UIImage imageNamed:@"importAsScrap"] forState:UIControlStateNormal];
        [importAsScrapButton setBackgroundImage:[UIImage imageNamed:@"importAsScrapHighlighted"] forState:UIControlStateSelected];
        [importAsScrapButton addTarget:self action:@selector(setImportType:) forControlEvents:UIControlEventTouchUpInside];
        importAsScrapButton.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:kImportAsPagePreferenceDefault];

        MMButtonBoxView* importButtonBox = [[MMButtonBoxView alloc] init];
        [importButtonBox setButtons:@[importAsPageButton, importAsScrapButton]];
        [importButtonBox setButtonSize:CGSizeMake(kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [importButtonBox setButtonMargin:kWidthOfSidebarButtonBuffer];
        [importButtonBox sizeToFit];
        [importButtonBox setTranslatesAutoresizingMaskIntoConstraints:NO];

        [slidingSidebarView addSubview:importButtonBox];

        // camera
        cameraAlbumButton = [[MMCameraButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        cameraAlbumButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        cameraAlbumButton.shadowInset = -1;
        [cameraAlbumButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        // albums
        iPhotoAlbumButton = [[MMImageViewButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [iPhotoAlbumButton setImage:[UIImage imageNamed:@"clearphotoalbum"]];
        [iPhotoAlbumButton addTarget:self action:@selector(albumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoAlbumButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoAlbumButton.shadowInset = -1;

        // faces button
        iPhotoFacesButton = [[MMFaceButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [iPhotoFacesButton addTarget:self action:@selector(faceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoFacesButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoFacesButton.shadowInset = -1;

        // event button
        iPhotoEventsButton = [[MMPalmTreeButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [iPhotoEventsButton addTarget:self action:@selector(eventButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iPhotoEventsButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        iPhotoEventsButton.shadowInset = -1;

        // pdf button
        inboxButton = [[MMInboxButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [inboxButton addTarget:self action:@selector(inboxButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        inboxButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        inboxButton.shadowInset = -1;

        // shape button
        shapeButton = [[MMShapesButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [shapeButton addTarget:self action:@selector(shapesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        shapeButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        shapeButton.shadowInset = -1;

        // shape button
        emojiButton = [[MMShapesButton alloc] initWithFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))];
        [emojiButton addTarget:self action:@selector(emojiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        emojiButton.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        emojiButton.shadowInset = -1;

        MMButtonBoxView* buttonBox = [[MMButtonBoxView alloc] init];

        [buttonBox setButtons:@[cameraAlbumButton, iPhotoAlbumButton, iPhotoFacesButton, iPhotoEventsButton, inboxButton, shapeButton, emojiButton]];
        [buttonBox setColumns:5];
        [buttonBox sizeToFit];
        [buttonBox setTranslatesAutoresizingMaskIntoConstraints:NO];
        [slidingSidebarView addSubview:buttonBox];

        [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:importButtonBox attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:slidingSidebarView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-26]];
        [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:buttonBox attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:slidingSidebarView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-26]];

        [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:importButtonBox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:slidingSidebarView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:buttonBox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:importButtonBox attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

        //////////////////////////////////////////
        // content

        void (^setupConstraintsForContentView)(UIView*) = ^(UIView* contentView) {
            CGFloat width = CGRectGetWidth(contentBounds);

            [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:buttonBox attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
            [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:slidingSidebarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            [slidingSidebarView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:slidingSidebarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        };

        cameraListContentView = [[MMCameraSidebarContentView alloc] initWithFrame:contentBounds];
        [cameraListContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        cameraListContentView.delegate = self;
        [slidingSidebarView addSubview:cameraListContentView];

        albumListContentView = [[MMAlbumSidebarContentView alloc] initWithFrame:contentBounds];
        [albumListContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        albumListContentView.delegate = self;
        [slidingSidebarView addSubview:albumListContentView];
        albumListContentView.hidden = YES;

        faceListContentView = [[MMFaceSidebarContentView alloc] initWithFrame:contentBounds];
        [faceListContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        faceListContentView.delegate = self;
        [slidingSidebarView addSubview:faceListContentView];
        faceListContentView.hidden = YES;

        eventListContentView = [[MMEventSidebarContentView alloc] initWithFrame:contentBounds];
        [eventListContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        eventListContentView.delegate = self;
        [slidingSidebarView addSubview:eventListContentView];
        eventListContentView.hidden = YES;

        inboxListContentView = [[MMInboxContentView alloc] initWithFrame:contentBounds];
        [inboxListContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        inboxListContentView.delegate = self;
        [slidingSidebarView addSubview:inboxListContentView];
        inboxListContentView.hidden = YES;

        shapeContentView = [[MMShapeSidebarContentView alloc] initWithFrame:contentBounds];
        [shapeContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        shapeContentView.delegate = self;
        [slidingSidebarView addSubview:shapeContentView];
        shapeContentView.hidden = YES;

        emojiContentView = [[MMEmojiSidebarContentView alloc] initWithFrame:contentBounds];
        [emojiContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        emojiContentView.delegate = self;
        [slidingSidebarView addSubview:emojiContentView];
        emojiContentView.hidden = YES;

        allListContentViews = [NSArray arrayWithObjects:cameraListContentView, albumListContentView, faceListContentView, eventListContentView, inboxListContentView, shapeContentView, emojiContentView, nil];

        for (UIView* contentView in allListContentViews) {
            setupConstraintsForContentView(contentView);
        }

        [self highlightButton:cameraAlbumButton];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setImportType:(id)sender {
    importAsPageButton.selected = (importAsPageButton == sender);
    importAsScrapButton.selected = (importAsScrapButton == sender);

    [[NSUserDefaults standardUserDefaults] setBool:importAsPageButton.selected forKey:kImportAsPagePreferenceDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)show:(BOOL)animated {
    [super show:animated];
    if (!cameraListContentView.hidden) {
        [cameraListContentView show:animated];
    }
    if (!albumListContentView.hidden) {
        [albumListContentView show:animated];
    }
    if (!faceListContentView.hidden) {
        [faceListContentView show:animated];
    }
    if (!eventListContentView.hidden) {
        [eventListContentView show:animated];
    }
    if (!inboxListContentView.hidden) {
        [inboxListContentView show:animated];
    }
    if (!shapeContentView.hidden) {
        [shapeContentView show:animated];
    }
    if (!emojiContentView.hidden) {
        [emojiContentView show:animated];
    }
    [self updateInterfaceTo:[[MMRotationManager sharedInstance] lastBestOrientation] animated:NO];
}

- (void)hide:(BOOL)animated onComplete:(void (^)(BOOL))onComplete {
    [super hide:animated onComplete:^(BOOL finished) {
        [cameraListContentView hide:animated];
        [albumListContentView hide:animated];
        [faceListContentView hide:animated];
        [eventListContentView hide:animated];
        [inboxListContentView hide:animated];
        [shapeContentView hide:animated];
        [emojiContentView hide:animated];

        if (onComplete) {
            onComplete(finished);
        }
    }];
}

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView {
    [self.delegate pictureTakeWithCamera:img fromView:cameraView andRequestsImportAsPage:importAsPageButton.selected];
}

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(UIView<MMDisplayAssetCoordinator>*)assetView withBackgroundColor:(UIColor*)color withRotation:(CGFloat)rotation fromContainer:(MMAbstractSidebarContentView*)container {
    [self.delegate assetWasTapped:asset fromView:assetView withBackgroundColor:color withRotation:rotation fromContainer:[container description] andRequestsImportAsPage:importAsPageButton.selected];
}

- (void)switchToListView:(MMAbstractSidebarContentView*)listView {
    for (MMAbstractSidebarContentView* aListView in allListContentViews) {
        if (aListView == listView) {
            listView.hidden = NO;
            [listView reset:NO];
            [listView show:NO];
        } else if (!aListView.hidden) {
            [aListView hide:NO];
            aListView.hidden = YES;
        }
    }
}

- (void)highlightButton:(MMSidebarButton*)button {
    iPhotoAlbumButton.selected = NO;
    iPhotoEventsButton.selected = NO;
    iPhotoFacesButton.selected = NO;
    cameraAlbumButton.selected = NO;
    inboxButton.selected = NO;
    shapeButton.selected = NO;
    emojiButton.selected = NO;
    button.selected = YES;
}

- (void)cameraButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:cameraListContentView];
    [self highlightButton:button];
}

- (void)albumButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:albumListContentView];
    [self highlightButton:button];
}

- (void)faceButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:faceListContentView];
    [self highlightButton:button];
}

- (void)eventButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:eventListContentView];
    [self highlightButton:button];
}

- (void)inboxButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:inboxListContentView];
    [self highlightButton:button];
}

- (void)shapesButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:shapeContentView];
    [self highlightButton:button];
}

- (void)emojiButtonTapped:(MMSidebarButton*)button {
    [self switchToListView:emojiContentView];
    [self highlightButton:button];
}

- (void)showPDF:(MMInboxItem*)pdf {
    [self switchToListView:inboxListContentView];
    [inboxListContentView switchToPDFView:pdf];
    [self highlightButton:inboxButton];
}

- (void)refreshPDF {
    [inboxListContentView reset:NO];
}

#pragma mark - MMPhotoManagerDelegate

- (void)doneLoadingPhotoAlbums {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [cameraListContentView doneLoadingPhotoAlbums];
            [albumListContentView doneLoadingPhotoAlbums];
            [faceListContentView doneLoadingPhotoAlbums];
            [eventListContentView doneLoadingPhotoAlbums];
            [inboxListContentView doneLoadingPhotoAlbums];
            [shapeContentView doneLoadingPhotoAlbums];
            [emojiContentView doneLoadingPhotoAlbums];
        }
    });
}

- (void)albumUpdated:(MMPhotoAlbum*)updatedAlbum {
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
    [self updateInterfaceTo:orientation animated:YES];
}

- (void)updateInterfaceTo:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    CheckMainThread;

    if (![self isVisible])
        return;
    if (!cameraListContentView.hidden) {
        [cameraListContentView updatePhotoRotation:animated];
    } else if (!albumListContentView.hidden) {
        [albumListContentView updatePhotoRotation:animated];
    } else if (!faceListContentView.hidden) {
        [faceListContentView updatePhotoRotation:animated];
    } else if (!eventListContentView.hidden) {
        [eventListContentView updatePhotoRotation:animated];
    } else if (!inboxListContentView.hidden) {
        [inboxListContentView updatePhotoRotation:animated];
    } else if (!shapeContentView.hidden) {
        [shapeContentView updatePhotoRotation:animated];
    } else if (!emojiContentView.hidden) {
        [emojiContentView updatePhotoRotation:animated];
    }

    void (^animations)() = ^{
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

        shapeButton.rotation = [self sidebarButtonRotation];
        shapeButton.transform = rotationTransform;

        emojiButton.rotation = [self sidebarButtonRotation];
        emojiButton.transform = rotationTransform;

        importAsPageButton.transform = rotationTransform;
        importAsScrapButton.transform = rotationTransform;
    };

    [[NSThread mainThread] performBlock:^{
        if (animated) {
            [UIView animateWithDuration:.3 animations:animations];
        } else {
            animations();
        }
    }];
}


#pragma mark - Memory

- (void)killMemory {
    if (![self isVisible]) {
        [cameraListContentView killMemory];
        [albumListContentView killMemory];
        [faceListContentView killMemory];
        [eventListContentView killMemory];
        [inboxListContentView killMemory];
        [shapeContentView killMemory];
        [emojiContentView killMemory];
    }
}


@end
