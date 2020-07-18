//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "MMScrapPaperStackView.h"
#import "MMUntouchableView.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMDebugDrawView.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMStretchScrapGestureRecognizer.h"
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import <JotUI/UIImage+Resize.h>
#import "NSMutableSet+Extras.h"
#import "UIGestureRecognizer+GestureDebug.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMImageSidebarContainerView.h"
#import "MMBufferedImageView.h"
#import "MMBorderedCamView.h"
#import "MMInboxManager.h"
#import "MMInboxManagerDelegate.h"
#import "NSURL+UTI.h"
#import "Mixpanel.h"
#import "MMTrashManager.h"
#import "MMShareSidebarContainerView.h"
#import "MMPhotoManager.h"
#import "NSArray+Extras.h"
#import "MMStatTracker.h"
#import <PerformanceBezier/PerformanceBezier.h>
#import "MMTutorialView.h"
#import "MMPDFAssetGroup.h"
#import "MMStopWatch.h"
#import "MMAppDelegate.h"
#import "MMPDFPageAsset.h"
#import "MMImageInboxItem.h"
#import "MMPalmGestureRecognizer.h"
#import "NSURL+UTI.h"


@implementation MMScrapPaperStackView {
    MMScrapContainerView* scrapContainer;
    // we get two gestures here, so that we can support
    // grabbing two scraps at the same time
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture2;
    MMStretchScrapGestureRecognizer* stretchScrapGesture;

    // this is the initial transform of a scrap
    // before it's started to be stretched.
    CATransform3D startSkewTransform;

    NSTimer* debugTimer;
    NSTimer* drawTimer;
    UIImageView* debugImgView;

    // flag if we're waiting on a page to save
    MMPaperView* wantsExport;

    // flag if we're animating a scrap
    // to/from the sidebar
    BOOL isAnimatingScrapToOrFromSidebar;

    MMDeletePageSidebarController* deleteScrapSidebar;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid {
    if (frame.size.width > frame.size.height) {
        // force portrait build
        CGFloat t = frame.size.width;
        frame.size.width = frame.size.height;
        frame.size.height = t;
    }

    if ((self = [super initWithFrame:frame andUUID:_uuid])) {
        self.autoresizingMask = UIViewAutoresizingNone;

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];

        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture2];

        stretchScrapGesture = [[MMStretchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(stretchScrapGesture:)];
        stretchScrapGesture.scrapDelegate = self;
        stretchScrapGesture.pinchScrapGesture1 = panAndPinchScrapGesture;
        stretchScrapGesture.pinchScrapGesture2 = panAndPinchScrapGesture2;
        [self addGestureRecognizer:stretchScrapGesture];

        // make sure sidebar buttons hide the scrap menu
        for (MMSidebarButton* possibleSidebarButton in self.subviews) {
            if ([possibleSidebarButton isKindOfClass:[MMSidebarButton class]]) {
                [possibleSidebarButton addTarget:self action:@selector(anySidebarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }

        [insertImageButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [backgroundStyleButton addTarget:self action:@selector(backgroundStyleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        deleteScrapSidebar = [[MMDeletePageSidebarController alloc] initWithFrame:self.bounds andDarkBorder:YES];
        [self addSubview:deleteScrapSidebar.deleteSidebarBackground];

        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds forScrapsOnPaperState:nil];
        [self addSubview:scrapContainer];

        [self addSubview:deleteScrapSidebar.deleteSidebarForeground];

        _fromRightBezelGesture.panDelegate = self;
        _fromLeftBezelGesture.panDelegate = self;
    }
    return self;
}

- (int)fullByteSize {
    return [super fullByteSize];
}

#pragma mark - Insert Image

- (void)insertImageButtonTapped:(UIButton*)_button {
    [[MMPhotoManager sharedInstance] bypassAuthRequirement];
    [self cancelAllGestures];
    [[self.visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [self.stackDelegate.importImageSidebar show:YES];
}

#pragma mark - MMInboxManagerDelegate

- (void)failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    if ([[url scheme] hasPrefix:@"pin"]) {
        // pinterest export completed successfully
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{ kMPEventExportPropDestination: @"Pinterest",
                                                                      kMPEventExportPropResult: @"Success" }];
    } else {
        // log this to mixpanel
        NSString* fileExtension = [url fileExtension] ? [url fileExtension] : @"nofile";
        NSString* typeId = [url universalTypeID] ? [url universalTypeID] : @"notype";
        [[Mixpanel sharedInstance] track:kMPEventImportPhotoFailed properties:@{kMPEventImportPropFileExt: fileExtension,
                                                                                kMPEventImportPropFileType: typeId,
                                                                                kMPEventImportPropSource: kMPEventImportPropSourceApplication,
                                                                                kMPEventImportPropReferApp: sourceApplication}];
    }
}


- (BOOL)imageMatchesPaperDimensions:(MMImageInboxItem*)img {
    CGSize stackSize = self.visibleStackHolder.bounds.size;
    CGSize imgSize = [img sizeForPage:0];

    if (stackSize.width == imgSize.width &&
        stackSize.height == imgSize.height) {
        // perfect match
        return YES;
    } else {
        CGFloat scale = stackSize.width / imgSize.width;
        if (stackSize.height == scale * imgSize.height) {
            // aspect ratio matches
            return YES;
        }
    }
    // what if we rotated?
    stackSize.width = self.visibleStackHolder.bounds.size.height;
    stackSize.height = self.visibleStackHolder.bounds.size.width;
    if (stackSize.width == imgSize.width &&
        stackSize.height == imgSize.height) {
        // perfect match
        return YES;
    } else {
        CGFloat scale = stackSize.width / imgSize.width;
        if (stackSize.height == scale * imgSize.height) {
            // aspect ratio matches
            return YES;
        }
    }
    return NO;
}

- (void)didProcessIncomingImage:(MMImageInboxItem*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [self transitionFromListToNewBlankPageIfInPageView];
    // import after slight delay so the transition from the other app
    // can complete nicely
    [[NSThread mainThread] performBlock:^{
        if ([self imageMatchesPaperDimensions:scrapBacking]) {
            CGSize pageSize = self.hiddenStackHolder.bounds.size;
            [self importImageAsNewPage:[scrapBacking imageForPage:0 forMaxDim:MAX(pageSize.width, pageSize.height)] withAssetURL:url fromContainer:kMPEventImportPropSourceApplication referringApp:sourceApplication onComplete:^(MMExportablePaperView* page) {
                [self.hiddenStackHolder pushSubview:page];
                [page saveToDisk:nil];
                [page loadCachedPreviewAndDecompressImmediately:NO]; // needed to make sure the background is showing properly
                [page updateThumbnailVisibility];
                [[self.visibleStackHolder peekSubview] enableAllGestures];
                [self popTopPageOfHiddenStack];
                [self.stackDelegate.importImageSidebar hide:YES onComplete:nil];
            }];
            return;
        }

        [self.stackDelegate.importImageSidebar hide:NO onComplete:^(BOOL finished) {
            [self importImageAsNewScrap:[scrapBacking imageForPage:0 forMaxDim:kPhotoImportMaxDim]];
            [self.stackDelegate.importImageSidebar refreshPDF];
        }];

        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfImports by:@(1)];
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{kMPEventImportPropFileExt: [url fileExtension],
                                                                          kMPEventImportPropFileType: [url universalTypeID],
                                                                          kMPEventImportPropSource: kMPEventImportPropSourceApplication,
                                                                          kMPEventImportPropReferApp: sourceApplication}];
    } afterDelay:.75];
}

- (void)didProcessIncomingPDF:(MMPDFInboxItem*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [[NSThread mainThread] performBlock:^{
        if (pdfDoc.isEncrypted) {
            // show PDF sidebar
            [[MMPhotoManager sharedInstance] bypassAuthRequirement];
            [self cancelAllGestures];
            [[self.visibleStackHolder peekSubview] cancelAllGestures];
            [self setButtonsVisible:NO withDuration:0.15];
            [self.stackDelegate.importImageSidebar refreshPDF];
            [self.stackDelegate.importImageSidebar show:YES];
        } else if (pdfDoc.pageCount == 1) {
            [self.stackDelegate.importImageSidebar hide:NO onComplete:^(BOOL finished) {
                // create a UIImage from the PDF and add it like normal above
                // immediately import that single page
                MMPDFAssetGroup* pdfAlbum = [[MMPDFAssetGroup alloc] initWithInboxItem:pdfDoc];
                NSIndexSet* pageSet = [NSIndexSet indexSetWithIndex:0];
                [pdfAlbum loadPhotosAtIndexes:pageSet usingBlock:^(MMDisplayAsset* result, NSUInteger index, BOOL* stop) {
                    UIImage* pageImage = [result aspectThumbnailWithMaxPixelSize:kPDFImportMaxDim];
                    [self importImageAsNewScrap:pageImage];
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // make sure PDF sidebar shows refreshed data
                    [self.stackDelegate.importImageSidebar refreshPDF];
                });
            }];
        } else {
            // automatically open to the PDF in the import sidebar
            [[MMPhotoManager sharedInstance] bypassAuthRequirement];
            [self cancelAllGestures];
            [[self.visibleStackHolder peekSubview] cancelAllGestures];
            [self setButtonsVisible:NO withDuration:0.15];
            [self.stackDelegate.importImageSidebar show:YES];

            // show show the PDF content in the sidebar
            [self.stackDelegate.importImageSidebar showPDF:pdfDoc];
        }
    } afterDelay:.75];


    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfImports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{ kMPEventImportPropFileExt: [url fileExtension],
                                                                       kMPEventImportPropFileType: [url universalTypeID],
                                                                       kMPEventImportPropSource: kMPEventImportPropSourceApplication,
                                                                       kMPEventImportPropPDFPageCount: @(pdfDoc.pageCount),
                                                                       kMPEventImportPropReferApp: sourceApplication }];
}

//
// adds the incoming image as a new scrap to the top page
// throws exception if in list view
- (void)importImageAsNewScrap:(UIImage*)scrapBacking {
    if ([self isShowingPageView]) {
        [self importImageOntoTopVisibleAndLoadedPage:scrapBacking];
    } else {
        [self transitionFromListToNewBlankPageIfInPageView];
        [self performSelector:@selector(importImageOntoTopVisibleAndLoadedPage:) withObject:scrapBacking afterDelay:.2];
    }
}

- (void)importImageOntoTopVisibleAndLoadedPage:(UIImage*)scrapBacking {
    MMScrappedPaperView* topPage = [self.visibleStackHolder peekSubview];
    if (![topPage isStateLoaded]) {
        // if our state isn't loaded yet, then just wait a bit
        // and try the import again soon.
        [self performSelector:@selector(importImageOntoTopVisibleAndLoadedPage:) withObject:scrapBacking afterDelay:.2];
        return;
    }

    MMVector* up = [[MMRotationManager sharedInstance] upVector];
    MMVector* perp = [[up perpendicular] normal];
    CGPoint center = CGPointMake(ceilf((self.bounds.size.width - scrapBacking.size.width) / 2),
                                 ceilf((self.bounds.size.height - scrapBacking.size.height) / 2));
    // start the photo "up" and have it drop down into the center ish of the page
    center = [up pointFromPoint:center distance:80];
    // randomize it a bit
    center = [perp pointFromPoint:center distance:(random() % 80) - 40];


    // subtract 1px from the border so that the background is clipped nicely around the edge
    CGSize scrapSize = CGSizeMake(scrapBacking.size.width - 2, scrapBacking.size.height - 2);
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(center.x, center.y, scrapSize.width, scrapSize.height)];

    MMScrapView* scrap = [topPage addScrapWithPath:path andRotation:RandomPhotoRotation(rand()) andScale:1.0];
    [scrapContainer addSubview:scrap];

    // background fills the entire scrap
    [scrap setBackgroundView:[[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state]];


    // prep the scrap to fade in while it drops on screen
    scrap.alpha = .3;
    scrap.scale = 1.2;

    // bounce by 20px (10 on each side)
    CGFloat bounceScale = 20 / MAX(scrapSize.width, scrapSize.height);

    // animate the scrap dropping and bouncing on the page
    [UIView animateWithDuration:.2
        delay:.1
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            // doesn't need to land exactly center. this way
            // multiple imports of multiple photos won't all
            // land exactly on top of each other. looks nicer.
            MMScrappedPaperView* page = [self.visibleStackHolder peekSubview];
            CGPoint center = CGPointMake(page.bounds.size.width / 2, page.bounds.size.height / 2);
            // scale the center point to 1.0 scale
            center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(1 / page.scale, 1 / page.scale));
            // at this point, we have the true center of the page,
            // now add a bit of random to it to give it some variance
            center.x += random() % 14 - 7;
            center.y += random() % 14 - 7;
            scrap.center = center;
            [scrap setScale:(1 - bounceScale) andRotation:RandomPhotoRotation(rand())];
            scrap.alpha = .72;
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:.1
                delay:0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    [scrap setScale:1];
                    scrap.alpha = 1.0;
                }
                completion:^(BOOL finished) {
                    [topPage.scrapsOnPaperState showScrap:scrap];
                    [topPage saveToDisk:nil];
                }];
        }];
}


#pragma mark - MMImageSidebarContainerViewDelegate

- (void)disableAllGesturesForPageView {
    DebugLog(@"disableAllGesturesForPageView");
    [panAndPinchScrapGesture setEnabled:NO];
    [panAndPinchScrapGesture2 setEnabled:NO];
    [stretchScrapGesture setEnabled:NO];
    [super disableAllGesturesForPageView];
}

- (void)enableAllGesturesForPageView {
    DebugLog(@"enableAllGesturesForPageView");
    [panAndPinchScrapGesture setEnabled:YES];
    [panAndPinchScrapGesture2 setEnabled:YES];
    [stretchScrapGesture setEnabled:YES];
    [super enableAllGesturesForPageView];
}

- (void)sidebarCloseButtonWasTapped:(MMFullScreenSidebarContainingView*)sidebar {
    // noop
}

- (void)sidebarWillShow:(MMFullScreenSidebarContainingView*)sidebar {
    [self disableAllGesturesForPageView];
}

- (void)sidebarWillHide:(MMFullScreenSidebarContainingView*)sidebar {
    [self setButtonsVisible:YES animated:YES];
    [self enableAllGesturesForPageView];
}

- (void)importImageAsNewPage:(UIImage*)imageToImport withAssetURL:(NSURL*)inAssetURL fromContainer:(NSString*)containerDescription referringApp:(NSString*)sourceApplication onComplete:(void (^)(MMExportablePaperView*))completionBlock {
    MMExportablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:self.hiddenStackHolder.bounds];
    page.delegate = self;
    __block NSURL* assetURL = inAssetURL;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGSize thumbSize = self.hiddenStackHolder.bounds.size;
        thumbSize.width = floorf(thumbSize.width / 2);
        thumbSize.height = floorf(thumbSize.height / 2);

        [NSFileManager ensureDirectoryExistsAtPath:[page pagesPath]];
        [MMBackgroundedPaperView writeBackgroundImageToDisk:imageToImport backgroundTexturePath:[page backgroundTexturePath]];

        CGFloat scale = [[UIScreen mainScreen] scale];
        UIGraphicsBeginImageContextWithOptions(thumbSize, NO, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGSize imgSize = [imageToImport size];

        if (imageToImport && imgSize.width > imgSize.height) {
            // if the PDF is landscape, then we need to rotate our
            // canvas so that the landscape PDF is drawn on our
            // vertical canvas properly.
            CGFloat theta = 90.0 * M_PI / 180.0;

            CGContextTranslateCTM(context, thumbSize.width / 2, thumbSize.height / 2);
            CGContextRotateCTM(context, theta);
            CGContextTranslateCTM(context, -thumbSize.height / 2, -thumbSize.width / 2);

            thumbSize = CGSizeSwap(thumbSize);
        }

        CGRect rectForImage = CGSizeFill(imgSize, thumbSize);
        [imageToImport drawInRect:rectForImage];

        UIImage* thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();


        [MMExportablePaperView writeThumbnailImagesToDisk:thumbnailImage thumbnailPath:[page thumbnailPath] scrappedThumbnailPath:[page scrappedThumbnailPath]];
        if (!assetURL) {
            NSString* tmpImagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];
            [UIImagePNGRepresentation(imageToImport) writeToFile:tmpImagePath atomically:YES];
            assetURL = [NSURL fileURLWithPath:tmpImagePath];
        }
        [page saveOriginalBackgroundTextureFromURL:assetURL];

        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
        [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedPage: @(YES) }];

        NSMutableDictionary* properties = [@{ kMPEventImportPropFileExt: [assetURL fileExtension] ?: @"png",
                                              kMPEventImportPropFileType: [assetURL universalTypeID] ?: [NSURL UTIForExtension:@"png"],
                                              kMPEventImportPropResult: @"Success" } mutableCopy];
        if (containerDescription) {
            properties[kMPEventImportPropSource] = containerDescription;
        }
        if (sourceApplication) {
            properties[kMPEventImportPropSourceApplication] = sourceApplication;
        }

        [[Mixpanel sharedInstance] track:kMPEventImportPage properties:properties];

        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(page);
            });
        }
    });
}

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView andRequestsImportAsPage:(BOOL)asPage {
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotosTaken by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventTakePhoto];

    if (asPage) {
        CGSize pageSize = self.hiddenStackHolder.bounds.size;
        img = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:pageSize interpolationQuality:kCGInterpolationHigh];
        [self importImageAsNewPage:img withAssetURL:nil fromContainer:@"Camera" referringApp:nil onComplete:^(MMExportablePaperView* page) {
            [self.hiddenStackHolder pushSubview:page];
            [page saveToDisk:nil];
            [page loadCachedPreviewAndDecompressImmediately:NO]; // needed to make sure the background is showing properly
            [page updateThumbnailVisibility];
            [[self.visibleStackHolder peekSubview] enableAllGestures];
            [self popTopPageOfHiddenStack];
            [self.stackDelegate.importImageSidebar hide:YES onComplete:nil];
        }];
        return;
    }


    CGRect scrapRect = CGRectZero;
    scrapRect.origin = [self convertPoint:cameraView.layer.bounds.origin fromView:cameraView];
    scrapRect.size = cameraView.bounds.size;
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:scrapRect];

    //
    // to exactly align the scrap with a rotation,
    // i would need to rotate it around its top left corner
    // this is because we're creating the rect to align
    // with the point tl above, which when converted
    // into our coordinate system accounts for the view's
    // rotation.
    //
    // so at this moment, we have a squared off CGRect
    // that aligns it's top left corner to the rotated
    // bufferedImage's top left corner


    // max image size in any direction is 300pts
    CGFloat maxDim = 600;

    CGSize fullScale = img.size;
    if (fullScale.width >= fullScale.height && fullScale.width > maxDim) {
        fullScale.height = fullScale.height / fullScale.width * maxDim;
        fullScale.width = maxDim;
    } else if (fullScale.height >= fullScale.width && fullScale.height > maxDim) {
        fullScale.width = fullScale.width / fullScale.height * maxDim;
        fullScale.height = maxDim;
    }

    CGFloat startingScale = scrapRect.size.width / fullScale.width;

    UIImage* scrapBacking = [img resizedImage:CGSizeMake(ceilf(fullScale.width / 2), ceilf(fullScale.height / 2)) interpolationQuality:kCGInterpolationMedium];

    MMUndoablePaperView* topPage = [self.visibleStackHolder peekSubview];
    MMScrapView* scrap = [topPage addScrapWithPath:path andRotation:0 andScale:startingScale];
    [[MMStatTracker trackerWithName:kMPStatScrapPathSegments] trackValue:scrap.bezierPath.elementCount];
    [scrapContainer addSubview:scrap];

    CGSize fullScaleScrapSize = scrapRect.size;
    fullScaleScrapSize.width /= startingScale;
    fullScaleScrapSize.height /= startingScale;

    // zoom the background in an extra pixel
    // so that the border of the image exceeds the
    // path of the scrap. this'll give us a nice smooth
    // edge from the mask of the CAShapeLayer
    CGFloat scaleUpOfImage = fullScaleScrapSize.width / scrapBacking.size.width + 2.0 / scrapBacking.size.width; // extra pixel

    // add the background, and scale it so it fills the scrap
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state];
    backgroundView.backgroundScale = scaleUpOfImage;
    [scrap setBackgroundView:backgroundView];

    // center the scrap on top of the camera view
    // so we can slide it onto the page
    scrap.center = [self convertPoint:CGPointMake(cameraView.bounds.size.width / 2, cameraView.bounds.size.height / 2) fromView:cameraView];
    scrap.rotation = cameraView.rotation;

    [self.stackDelegate.importImageSidebar hide:YES onComplete:nil];

    // hide the photo in the row
    cameraView.alpha = 0;

    // bounce by 20px (10 on each side)
    CGFloat bounceScale = 20 / MAX(fullScale.width, fullScale.height);

    [UIView animateWithDuration:.2
        delay:.1
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            scrap.center = [self.visibleStackHolder peekSubview].center;
            [scrap setScale:(1 + bounceScale) andRotation:RandomPhotoRotation(rand())];
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:.1
                delay:0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    [scrap setScale:1];
                }
                completion:^(BOOL finished) {
                    cameraView.alpha = 1;
                    [topPage.scrapsOnPaperState showScrap:scrap];
                    [topPage addUndoItemForAddedScrap:scrap];
                    [topPage saveToDisk:nil];
                }];
        }];
}

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(UIView<MMDisplayAssetCoordinator>*)bufferedImage withBackgroundColor:(UIColor*)color withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription andRequestsImportAsPage:(BOOL)asPage {
    CheckMainThread;
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfImports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];

    NSURL* assetURL = asset.fullResolutionURL;
    [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{kMPEventImportPropFileExt: [assetURL fileExtension],
                                                                      kMPEventImportPropFileType: [assetURL universalTypeID],
                                                                      kMPEventImportPropSource: containerDescription}];

    CGRect scrapRect = CGRectZero;
    CGSize buttonSize = [bufferedImage visibleImageSize];

    // max image size in any direction
    CGFloat maxDim = [asset preferredImportMaxDim] * [[UIScreen mainScreen] scale];

    if (asPage) {
        CGSize pageSize = self.hiddenStackHolder.bounds.size;
        [self importImageAsNewPage:[asset aspectThumbnailWithMaxPixelSize:maxDim andRatio:pageSize.width / pageSize.height] withAssetURL:assetURL fromContainer:containerDescription referringApp:nil onComplete:^(MMExportablePaperView* page) {
            [self.hiddenStackHolder pushSubview:page];
            [page saveToDisk:nil];
            [page loadCachedPreviewAndDecompressImmediately:NO]; // needed to make sure the background is showing properly
            [page updateThumbnailVisibility];
            [[self.visibleStackHolder peekSubview] enableAllGestures];
            [self popTopPageOfHiddenStack];
            [self.stackDelegate.importImageSidebar hide:YES onComplete:nil];
        }];
        return;
    }

    UIImage* scrapBacking = [asset aspectThumbnailWithMaxPixelSize:maxDim];
    CGSize scrapBackingSize = [asset resolutionSizeWithMaxDim:maxDim];

    CGSize fullScaleSize = CGSizeScale(scrapBackingSize, 1 / [[UIScreen mainScreen] scale]);

    // force the rect path that we're building to
    // match the aspect ratio of the input photo
    CGFloat ratio = buttonSize.width / fullScaleSize.width;
    buttonSize.height = fullScaleSize.height * ratio;

    scrapRect.origin = [self convertPoint:[bufferedImage visibleImageOrigin] fromView:bufferedImage];
    scrapRect.size = buttonSize;

    UIImageOrientation (^rotateOrientationLeft)(UIImageOrientation) = ^(UIImageOrientation initialOrientation) {
        if (initialOrientation == UIImageOrientationUp || initialOrientation == UIImageOrientationUpMirrored) {
            return UIImageOrientationLeft;
        } else if (initialOrientation == UIImageOrientationLeft || initialOrientation == UIImageOrientationLeftMirrored) {
            return UIImageOrientationDown;
        } else if (initialOrientation == UIImageOrientationDown || initialOrientation == UIImageOrientationDownMirrored) {
            return UIImageOrientationRight;
        } else if (initialOrientation == UIImageOrientationRight || initialOrientation == UIImageOrientationRightMirrored) {
            return UIImageOrientationUp;
        }

        return UIImageOrientationUp;
    };

    if (scrapBacking && fullScaleSize.width > fullScaleSize.height) {
        fullScaleSize = CGSizeSwap(fullScaleSize);
        scrapRect.size = CGSizeSwap(scrapRect.size);
        scrapBackingSize = CGSizeSwap(scrapBackingSize);
        rotation += M_PI / 2.0;
        scrapBacking = [UIImage imageWithCGImage:scrapBacking.CGImage scale:scrapBacking.scale orientation:rotateOrientationLeft(scrapBacking.imageOrientation)];
    }


    UIBezierPath* originalPath;
    UIBezierPath* path;

    if (![asset fullResolutionPath]) {
        path = [UIBezierPath bezierPathWithRect:scrapRect];
        originalPath = [UIBezierPath bezierPathWithRect:CGRectFromSize(fullScaleSize)];
    } else {
        path = [asset fullResolutionPath];
        originalPath = [path copy];
        [path applyTransform:CGAffineTransformMakeScale(ratio, ratio)];
        [path applyTransform:CGAffineTransformMakeTranslation(scrapRect.origin.x, scrapRect.origin.y)];
    }

    //
    // to exactly align the scrap with a rotation,
    // i would need to rotate it around its top left corner
    // this is because we're creating the rect to align
    // with the point tl above, which when converted
    // into our coordinate system accounts for the view's
    // rotation.
    //
    // so at this moment, we have a squared off CGRect
    // that aligns it's top left corner to the rotated
    // bufferedImage's top left corner


    CGFloat startingScale = scrapRect.size.width / fullScaleSize.width;

    MMUndoablePaperView* topPage = [self.visibleStackHolder peekSubview];

    void (^blockToAddScrapToPage)() = ^{
        MMScrapView* scrap = [topPage addScrapWithPath:path andRotation:rotation andScale:startingScale];
        [scrapContainer addSubview:scrap];
        [scrap setBackgroundColor:color ?: [UIColor whiteColor]];

        CGSize fullScaleScrapSize = scrapRect.size;
        fullScaleScrapSize.width /= startingScale;
        fullScaleScrapSize.height /= startingScale;

        // zoom the background in an extra pixel
        // so that the border of the image exceeds the
        // path of the scrap. this'll give us a nice smooth
        // edge from the mask of the CAShapeLayer
        CGFloat scaleUpOfImage = fullScaleScrapSize.width / scrapBackingSize.width + 2.0 / scrapBackingSize.width; // extra pixel

        // add the background, and scale it so it fills the scrap
        MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state];
        backgroundView.backgroundScale = scaleUpOfImage;
        // the background is offset from the center of the scrap,
        // so adjust its offset to account for the distance
        // from the top left of the scrap to the center of the scrap
        CGPoint bgCenter = CGPointMake(fullScaleScrapSize.width * scaleUpOfImage, fullScaleScrapSize.height * scaleUpOfImage);
        CGPoint scrapCenter = CGRectGetMidPoint(originalPath.bounds);
        CGPoint trueOffset = CGPointMake(scrapCenter.x - bgCenter.x, scrapCenter.y - bgCenter.y);
        trueOffset = CGPointScale(trueOffset, -1);
        backgroundView.backgroundOffset = trueOffset;
        [scrap setBackgroundView:backgroundView];

        // move the scrap so that it covers the image that was just tapped.
        // then we'll animate it onto the page
        scrap.center = [self convertPoint:CGPointMake(bufferedImage.bounds.size.width / 2, bufferedImage.bounds.size.height / 2) fromView:bufferedImage];
        scrap.rotation = rotation;

        // hide the picker, this'll slide it out
        // underneath our scrap
        [self.stackDelegate.importImageSidebar hide:YES onComplete:nil];

        // hide the photo in the row. this way the scrap
        // becomes the photo, and it doesn't seem to duplicate
        // as the image sidebar hides. the image in the sidebar
        // will reset after the sidebar is done hiding
        bufferedImage.alpha = 0;

        CGSize targetSizeAfterBounce = fullScaleSize;
        CGFloat targetScale = 1.0;
        if (MAX(targetSizeAfterBounce.width, targetSizeAfterBounce.height) > kMaxScrapImportSizeOnPageFromBounce) {
            targetSizeAfterBounce = CGSizeFit(targetSizeAfterBounce, CGSizeMake(kMaxScrapImportSizeOnPageFromBounce, kMaxScrapImportSizeOnPageFromBounce)).size;
        }
        targetScale = targetSizeAfterBounce.width / fullScaleSize.width;

        // bounce by 20px (10 on each side)
        CGFloat bounceScale = 20 / MAX(targetSizeAfterBounce.width, targetSizeAfterBounce.height);
        CGPoint targetCenter = [self.visibleStackHolder peekSubview].center;
        targetCenter.x += (RandomMod(time(NULL), 20) - 10);
        targetCenter.y += (RandomMod(time(NULL), 20) - 10);

        [UIView animateWithDuration:.2
            delay:.1
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                scrap.center = targetCenter;
                [scrap setScale:(targetScale + bounceScale) andRotation:scrap.rotation + RandomPhotoRotation(rand())];
            }
            completion:^(BOOL finished) {
                [UIView animateWithDuration:.1
                    delay:0
                    options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [scrap setScale:targetScale];
                    }
                    completion:^(BOOL finished) {
                        bufferedImage.alpha = 1;
                        [topPage.scrapsOnPaperState showScrap:scrap];
                        [topPage addUndoItemForAddedScrap:scrap];
                        [topPage saveToDisk:nil];
                    }];
            }];
    };


    if ([topPage.scrapsOnPaperState isStateLoaded]) {
        blockToAddScrapToPage();
    } else {
        [topPage performBlockForUnloadedScrapStateSynchronously:blockToAddScrapToPage andImmediatelyUnloadState:NO andSavePaperState:YES];
    }
}

#pragma mark - Gesture Helpers

- (void)cancelAllGestures {
    [super cancelAllGestures];
    [panAndPinchScrapGesture cancel];
    [panAndPinchScrapGesture2 cancel];
    [stretchScrapGesture cancel];
}


- (NSString*)debug_activeGestureSummary {
    NSMutableString* str = [NSMutableString stringWithString:@"\n\n\n"];
    [str appendString:@"begin\n"];

    for (MMPaperView* page in _setOfPagesBeingPanned) {
        if ([self.visibleStackHolder containsSubview:page]) {
            [str appendString:@"  1 page in visible stack\n"];
        } else if ([self.bezelStackHolder containsSubview:page]) {
            [str appendString:@"  1 page in bezel stack\n"];
        } else if ([self.hiddenStackHolder containsSubview:page]) {
            [str appendString:@"  1 page in hidden stack\n"];
        }
    }


    NSArray* allGesturesAndTopTwoPages = [self.gestureRecognizers arrayByAddingObjectsFromArray:[[self.visibleStackHolder peekSubview] gestureRecognizers]];
    allGesturesAndTopTwoPages = [allGesturesAndTopTwoPages arrayByAddingObjectsFromArray:[[self.visibleStackHolder getPageBelow:[self.visibleStackHolder peekSubview]] gestureRecognizers]];
    for (UIGestureRecognizer* gesture in allGesturesAndTopTwoPages) {
        UIGestureRecognizerState st = gesture.state;
        [str appendFormat:@"%@ %d\n", NSStringFromClass([gesture class]), (int)st];
        if ([gesture respondsToSelector:@selector(validTouches)]) {
            [str appendFormat:@"   validTouches: %d\n", (int)[[gesture performSelector:@selector(validTouches)] count]];
        }
        if ([gesture respondsToSelector:@selector(touches)]) {
            [str appendFormat:@"   touches: %d\n", (int)[[gesture performSelector:@selector(touches)] count]];
        }
        if ([gesture respondsToSelector:@selector(possibleTouches)]) {
            [str appendFormat:@"   possibleTouches: %d\n", (int)[[gesture performSelector:@selector(possibleTouches)] count]];
        }
        if ([gesture respondsToSelector:@selector(ignoredTouches)]) {
            [str appendFormat:@"   ignoredTouches: %d\n", (int)[[gesture performSelector:@selector(ignoredTouches)] count]];
        }
        if ([gesture respondsToSelector:@selector(paused)]) {
            [str appendFormat:@"   paused: %d\n", [gesture performSelector:@selector(paused)] ? 1 : 0];
        }
        if ([gesture respondsToSelector:@selector(scrap)]) {
            [str appendFormat:@"   has scrap: %d\n", [gesture performSelector:@selector(scrap)] ? 1 : 0];
        }
    }
    [str appendFormat:@"velocity gesture sees: %d\n", [[MMTouchVelocityGestureRecognizer sharedInstance] numberOfActiveTouches]];
    [str appendFormat:@"pages being panned %d\n", (int)[_setOfPagesBeingPanned count]];

    [str appendFormat:@"done\n"];

    for (MMScrapView* scrap in [[self.visibleStackHolder peekSubview] scrapsOnPaper]) {
        [str appendFormat:@"scrap: %f %f\n", scrap.layer.anchorPoint.x, scrap.layer.anchorPoint.y];
    }

    BOOL visibleStackHasDisabledPages = NO;
    BOOL hiddenStackHasEnabledPages = NO;
    for (MMPaperView* page in self.visibleStackHolder.subviews) {
        if (!page.areGesturesEnabled) {
            visibleStackHasDisabledPages = YES;
        }
    }
    for (MMPaperView* page in self.hiddenStackHolder.subviews) {
        if (page.areGesturesEnabled) {
            hiddenStackHasEnabledPages = YES;
        }
    }


    [str appendFormat:@"top visible page is disabled? %i\n", ![self.visibleStackHolder peekSubview].areGesturesEnabled];
    [str appendFormat:@"visible stack has disabled? %i\n", visibleStackHasDisabledPages];
    [str appendFormat:@"hidden stack has enabled? %i\n", hiddenStackHasEnabledPages];


    return str;
}

- (void)drawLine {
    [[[self.visibleStackHolder peekSubview] drawableView] drawLongLine];
}

#pragma mark - Add Page

- (void)addPageButtonTapped:(UIButton*)_button {
    [self forceScrapToScrapContainerDuringGesture];
    [super addPageButtonTapped:_button];
}

- (void)anySidebarButtonTapped:(id)button {
    if (button != self.stackDelegate.bezelScrapContainer.countButton) {
        [self.stackDelegate.bezelScrapContainer sidebarCloseButtonWasTapped];
    }
}

#pragma mark - Sharing

- (void)backgroundStyleButtonTapped:(UIButton*)_button {
    if ([self isActivelyGesturing]) {
        // export not allowed while gesturing
        return;
    }

    [self cancelAllGestures];
    [[self.visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [self.stackDelegate.backgroundStyleSidebar show:YES];
}

- (void)shareButtonTapped:(UIButton*)_button {
    if ([self isActivelyGesturing]) {
        // export not allowed while gesturing
        return;
    }

    [self cancelAllGestures];
    [[self.visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [self.stackDelegate.sharePageSidebar show:YES];
}

#pragma mark - MMPencilAndPaletteViewDelegate

- (void)highlighterTapped:(UIButton*)button {
    [super highlighterTapped:button];
    [self anySidebarButtonTapped:nil];
}

- (void)pencilTapped:(UIButton*)_button {
    [super pencilTapped:_button];
    [self anySidebarButtonTapped:nil];
}

- (void)markerTapped:(UIButton*)_button {
    [super markerTapped:_button];
    [self anySidebarButtonTapped:nil];
}

- (void)colorMenuToggled {
    [super colorMenuToggled];
    [self anySidebarButtonTapped:nil];
}

- (void)didChangeColorTo:(UIColor*)color fromUserInteraction:(BOOL)userInteraction {
    [super didChangeColorTo:color fromUserInteraction:userInteraction];
    [self anySidebarButtonTapped:nil];
}

#pragma mark - Bezel Gestures

- (void)forceScrapToScrapContainerDuringGesture {
    // if the gesture is cancelled, then don't move the scrap. to fix bezelling left over a scrap
    if (panAndPinchScrapGesture.scrap && panAndPinchScrapGesture.state != UIGestureRecognizerStateCancelled) {
        if (![scrapContainer.subviews containsObject:panAndPinchScrapGesture.scrap]) {
            [scrapContainer addSubview:panAndPinchScrapGesture.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture];
        }
    }
    if (panAndPinchScrapGesture2.scrap && panAndPinchScrapGesture2.state != UIGestureRecognizerStateCancelled) {
        if (![scrapContainer.subviews containsObject:panAndPinchScrapGesture2.scrap]) {
            [scrapContainer addSubview:panAndPinchScrapGesture2.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture2];
        }
    }
}

- (void)isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture {
    if (bezelGesture.subState != UIGestureRecognizerStatePossible &&
        bezelGesture.subState != UIGestureRecognizerStateFailed) {
        [self forceScrapToScrapContainerDuringGesture];
        [super isBezelingInLeftWithGesture:bezelGesture];
    }
}

- (void)isBezelingInRightWithGesture:(MMBezelInGestureRecognizer*)bezelGesture {
    if (bezelGesture.subState != UIGestureRecognizerStatePossible &&
        bezelGesture.subState != UIGestureRecognizerStateFailed) {
        [self forceScrapToScrapContainerDuringGesture];
        [super isBezelingInRightWithGesture:bezelGesture];
    }
}


#pragma mark - Panning Scraps

- (void)panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture {
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;

    if (_panGesture.paused) {
        return;
    }
    // TODO:
    // the first time the gesture comes back unpaused,
    // we need to make sure the scrap is in the correct place

    //
    BOOL didReset = NO;
    if (gesture.shouldReset) {
        gesture.shouldReset = NO;
        didReset = YES;
    }


    // Trash sidebar
    CGFloat trashPercentShown = 0;
    if (gesture.scrap) {
        CGPoint p = [self convertPoint:gesture.scrap.center fromView:gesture.scrap.superview];
        CGFloat x = 100 - p.x + 50;
        trashPercentShown = MAX(0, MIN(1.0, x / 100.0));

        // the scrap center will be the midpoint of the two fingers of the pan gesture
        // because we've reset the anchor point of the scrap during the gesture.

        [deleteScrapSidebar showSidebarWithPercent:trashPercentShown withTargetView:trashPercentShown ? gesture.scrap : nil];

        [self setButtonsVisible:![deleteScrapSidebar shouldDelete:gesture.scrap] animated:YES];
    }


    if (gesture.scrap && (gesture.scrap != stretchScrapGesture.scrap) && gesture.state != UIGestureRecognizerStateCancelled) {
        // handle the scrap.
        //
        // if the scrap is hovering over the page that it
        // originated from, then make sure to keep it
        // inside that page so that picking up a scrap
        // doesn't change the order of the scrap in the page

        //
        // first step:
        // find the center, scale, and rotation for the scrap
        // independent of any page
        MMScrapView* scrap = gesture.scrap;
        scrap.center = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                   gesture.translation.y + gesture.preGestureCenter.y);
        scrap.scale = gesture.preGestureScale * gesture.scale * gesture.preGesturePageScale;
        scrap.rotation = gesture.rotation + gesture.preGestureRotation;

        //
        // now determine if it should be inside of a page,
        // and what the page specific center and scale should be
        CGFloat scrapScaleInPage;
        CGPoint scrapCenterInPage;
        MMUndoablePaperView* pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
        if (![pageToDropScrap isEqual:[self.visibleStackHolder peekSubview]]) {
            // if the page it should drop isn't the top visible page,
            // then add it to the scrap container view.
            if (![scrapContainer.subviews containsObject:scrap]) {
                // just keep it in the scrap container
                [scrapContainer addSubview:scrap];
            }
        } else if (pageToDropScrap && [pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]) {
            // only adjust for the page if the page
            // already has the scrap. otherwise we'll keep
            // the scrap in the container view and only drop
            // it onto a page once the gesture is complete.
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = scrapCenterInPage;
        } else if (pageToDropScrap && ![pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]) {
            [self forceScrapToScrapContainerDuringGesture];
        }

        // only allow for shaking if:
        // 1. gesture is shaking
        // 2. there are other scraps on the page to re-order with, and
        // 3. we're not actively bezeling on a potentially different top page
        //    (since the bezel will pull the scrap to the scrapContainer anyways, there's
        //     no use adding an undo level for this shake)
        if (gesture.isShaking && [pageToDropScrap.scrapsOnPaper count] && ![_fromLeftBezelGesture isActivelyBezeling] && ![_fromRightBezelGesture isActivelyBezeling]) {
            // if the gesture is shaking, then pull the scrap to the top if
            // it's not already. otherwise send it to the back
            [[[Mixpanel sharedInstance] people] set:@{ kMPHasShakeToReorder: @(YES) }];
            if ([pageToDropScrap isEqual:[[MMPageCacheManager sharedInstance] currentEditablePage]] &&
                ![pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]) {
                // this happens when the user picks up a scrap
                // bezels / turns to another page while holding the scrap
                // and then shakes the scrap to re-order it on the new page

                // this page isn't allowed to steal another page's scrap,
                // so we need to clone it before passing it to the new page
                MMScrapView* clonedScrap = [self cloneScrap:gesture.scrap toPage:pageToDropScrap];
                // add the scrap to the bottom of the page
                [pageToDropScrap.scrapsOnPaperState showScrap:clonedScrap];
                [clonedScrap.superview insertSubview:clonedScrap atIndex:0];
                // remove the scrap from the original page
                [gesture.scrap removeFromSuperview];

                // add the undo items
                [gesture.startingPageForScrap addUndoItemForRemovedScrap:gesture.scrap withProperties:gesture.startingScrapProperties];
                [pageToDropScrap addUndoItemForAddedScrap:clonedScrap];

                // update the gesture to start working with the cloned scrap,
                // and make sure that this cloned scrap's anchor is at the
                // correct place so the swap is seamless
                [UIView setAnchorPoint:gesture.scrap.layer.anchorPoint forView:clonedScrap];
                gesture.scrap = clonedScrap;
                [clonedScrap setShouldShowShadow:YES];
                [clonedScrap setSelected:YES];

                // save the page we just dropped the scrap on
                [pageToDropScrap saveToDisk:nil];
            } else if (gesture.scrap == [gesture.scrap.superview.subviews lastObject]) {
                [gesture.scrap.superview insertSubview:gesture.scrap atIndex:0];
            } else {
                [gesture.scrap.superview addSubview:gesture.scrap];
            }
        }


        [self isBeginningToPanAndScaleScrapWithTouches:gesture.validTouches];
    }

    MMScrapView* scrapViewIfFinished = nil;

    BOOL shouldBezel = NO;
    if (gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                          gesture.state == UIGestureRecognizerStateCancelled ||
                          ![gesture.validTouches count])) {
        // turn off glow
        if (!stretchScrapGesture.scrap) {
            // only if that scrap isn't being stretched
            gesture.scrap.selected = NO;
        }

        //
        // notes for dropping scraps:
        //
        // Since the "center" of a scrap is changed to the gesture
        // location, I only need to check if the scrap center
        // is inside of a page, and make sure to add the scrap
        // to that page.

        NSArray* scrapsInContainer = scrapContainer.subviews;

        MMUndoablePaperView* pageToDropScrap = nil;
        if (gesture.didExitToBezel) {
            shouldBezel = YES;
            // remove scrap undo item
        } else if ([deleteScrapSidebar shouldDelete:gesture.scrap]) {
            // don't set any of its center/scale etc.
            // we don't want to potentially pass this scrap to
            // another page, just to delete it. we'll actually
            // handle the deletion in the next block
        } else if ([scrapsInContainer containsObject:gesture.scrap]) {
            CGFloat scrapScaleInPage;
            CGPoint scrapCenterInPage;
            if (gesture.state == UIGestureRecognizerStateCancelled) {
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
                if (pageToDropScrap == [self.visibleStackHolder peekSubview]) {
                    // it would drop on the visible page, so just
                    // do that
                    [self scaledCenter:&scrapCenterInPage andScale:&scrapScaleInPage forScrap:gesture.scrap onPage:pageToDropScrap];
                } else {
                    // it wouldn't have dropped on the visible page, so
                    // bezel it instead
                    shouldBezel = YES;
                }
            } else {
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
            }
            if (pageToDropScrap) {
                gesture.scrap.scale = scrapScaleInPage;
                gesture.scrap.center = scrapCenterInPage;

                if (pageToDropScrap != gesture.startingPageForScrap) {
                    // make remove/add scrap undo items
                    // need to somehow save which page used to
                    // own this scrap

                    // clone the scrap and add it to the
                    // page where it was dropped. this way, the
                    // original page can undo the move and get its
                    // own scrap back without adjusting the undo state
                    // of the page that the scrap was dropped on to.
                    //
                    // similarly, the page that had the scrap dropped onto
                    // it can undo the drop and it won't affect the page that
                    // the scrap came from
                    MMScrapView* clonedScrap = [self cloneScrap:gesture.scrap toPage:pageToDropScrap];
                    // remove the scrap from the original page
                    [gesture.scrap removeFromSuperview];

                    // add the undo items
                    [gesture.startingPageForScrap addUndoItemForRemovedScrap:gesture.scrap withProperties:gesture.startingScrapProperties];
                    [pageToDropScrap addUndoItemForAddedScrap:clonedScrap];
                } else {
                    // make a move-scrap undo item.
                    // we don't need to add an 'add scrap' undo item,
                    // since this is the page that originated the scrap
                    if (![pageToDropScrap.scrapsOnPaperState isScrapVisible:gesture.scrap]) {
                        [pageToDropScrap.scrapsOnPaperState showScrap:gesture.scrap];
                    }
                    [gesture.startingPageForScrap addUndoItemForScrap:gesture.scrap thatMovedFrom:gesture.startingScrapProperties to:[gesture.scrap propertiesDictionary]];
                }

                // https://github.com/adamwulf/loose-leaf/issues/877
                // when a scrap is picked up, and then pages are added/bezeled,
                // the original page's scrap state might be unloaded mid-gesture,
                // so we need to unload this scrap to match.
                if (![gesture.startingPageForScrap.scrapsOnPaperState isStateLoaded]) {
                    [gesture.scrap unloadState];
                }

                [pageToDropScrap saveToDisk:nil];
            } else {
                // couldn't find a page to catch it
                shouldBezel = YES;
            }
        } else {
            // scrap stayed on page
            // make a move-scrap undo item
            [gesture.startingPageForScrap addUndoItemForScrap:gesture.scrap thatMovedFrom:gesture.startingScrapProperties to:[gesture.scrap propertiesDictionary]];
        }

        // save teh page that the scrap came from
        MMEditablePaperView* pageThatGaveUpScrap = gesture.startingPageForScrap;
        if ((pageToDropScrap || shouldBezel) && pageThatGaveUpScrap != pageToDropScrap) {
            [pageThatGaveUpScrap saveToDisk:nil];
            [pageToDropScrap saveToDisk:nil];
        }
        scrapViewIfFinished = gesture.scrap;
    } else if (gesture.scrap && didReset) {
        // glow blue
        gesture.scrap.selected = YES;
    }
    if (gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                          gesture.state == UIGestureRecognizerStateFailed ||
                          gesture.state == UIGestureRecognizerStateCancelled ||
                          ![gesture.validTouches count])) {
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property

        // giving up the scrap will make sure
        // its anchor point is back in the true
        // center of the scrap. It'll also
        // nil out the scrap in the gesture, so
        // hang onto it
        MMScrapView* scrap = gesture.scrap;
        NSDictionary* startingScrapProperties = gesture.startingScrapProperties;
        MMUndoablePaperView* startingPageForScrap = gesture.startingPageForScrap;

        // need to check this bool before [giveUpScrap], since that will
        // reset its anchor point and change the calculation made
        // by the deleteScrapSidebar
        BOOL shouldDelete = [deleteScrapSidebar shouldDelete:gesture.scrap];

        [gesture giveUpScrap];

        if (shouldDelete) {
            // set our block so that we add an undo item after the scrap
            // has been removed from view
            __weak MMScrapPaperStackView* weakSelf = self;
            deleteScrapSidebar.deleteCompleteBlock = ^(UIView* viewToDelete) {
                [startingPageForScrap addUndoItemForRemovedScrap:scrap withProperties:startingScrapProperties];
                [weakSelf finishedPanningAndScalingScrap:scrap];
            };

            // delete the scrap after resetting its anchor point
            // so that the delete animation is guaranteed to remove
            // the entire scrap from the screen before [removeFromSuperview]
            [deleteScrapSidebar deleteView:scrap onComplete:nil];
        }

        // if our delete sidebar was visible, then we need
        // to reset our buttons + close the sidebar
        [self setButtonsVisible:YES animated:YES];
        [deleteScrapSidebar closeSidebarAnimated];

        if (shouldBezel) {
            [[[Mixpanel sharedInstance] people] set:@{ kMPHasBezelledScrap: @(YES) }];

            [startingPageForScrap addUndoItemForBezeledScrap:scrap withProperties:startingScrapProperties];
            // if we've bezelled the scrap,
            // add it to the bezel container
            [self.stackDelegate.bezelScrapContainer addViewToCountableSidebar:scrap animated:YES];
        }
    }
    if (scrapViewIfFinished) {
        [self finishedPanningAndScalingScrap:scrapViewIfFinished];
    }
}


/**
 * this method will return the page that could contain the scrap
 * given it's current position on the screen and the pages' postions
 * on the screen.
 *
 * it will return the page that should "catch" the scrap, and the
 * center/scale for the scrap on that page
 *
 * if no page could catch it, this will return nil
 */
- (MMUndoablePaperView*)pageWouldDropScrap:(MMScrapView*)scrap atCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage {
    MMUndoablePaperView* pageToDropScrap = nil;
    CGRect pageBounds;
    //
    // we want to be able to drop scraps
    // onto any page in the visible or bezel stack
    //
    // since the bezel pages are "above" the visible stack,
    // we should check them first
    //
    // these pages are in reverse order, so the last object in the
    // array is the top most visible page.

    //
    // I used to just create an NSMutableArray that contained the
    // combined visible and bezel stacks of subviews. but that was
    // fairly resource intensive for a method that needs to be extremely
    // quick.
    //
    // instead of an NSMutableArray, i create a C array pointing to
    // the arrays we already have. then our do:while loop will walk
    // backwards on the 2nd array, then walk backwards on the first
    // array until a page is found.
    NSArray* arrayOfArrayOfViews[2];
    arrayOfArrayOfViews[0] = self.visibleStackHolder.subviews;
    arrayOfArrayOfViews[1] = self.bezelStackHolder.subviews;
    int arrayNum = 1;
    int indexNum = (int)[self.bezelStackHolder.subviews count] - 1;

    do {
        if (indexNum < 0) {
            // if our index is less than zero, then we haven't been able
            // to find a page in our current array. move to the next array
            // of views further back in the view, and start checking those
            arrayNum -= 1;
            if (arrayNum == -1) {
                // failsafe.
                // this may happen if the user picks up two scraps with system gestures turned on.
                // the system may exit our app, leaving us in an unknown state
                return [self.visibleStackHolder peekSubview];
            }
            indexNum = (int)[(arrayOfArrayOfViews[arrayNum])count] - 1;
        }
        // fetch the most visible page
        NSArray* arrayOfViews = arrayOfArrayOfViews[arrayNum];
        pageToDropScrap = (indexNum >= 0 && indexNum < [arrayOfViews count]) ? [arrayOfViews objectAtIndex:indexNum] : nil;
        if (!pageToDropScrap) {
            // if we can't find a page, we're done
            break;
        }
        [self scaledCenter:scrapCenterInPage andScale:scrapScaleInPage forScrap:scrap onPage:pageToDropScrap];
        // bounds respects the transform, so we need to scale the
        // bounds of the page too to see if the scrap is landing inside
        // of it
        pageBounds = pageToDropScrap.bounds;
        CGFloat pageScale = pageToDropScrap.scale;
        CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1 / pageScale, 1 / pageScale);
        pageBounds = CGRectApplyAffineTransform(pageBounds, reverseScaleTransform);

        indexNum -= 1;
    } while (!CGRectContainsPoint(pageBounds, *scrapCenterInPage));

    return pageToDropScrap;
}

- (void)scaledCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage forScrap:(MMScrapView*)scrap onPage:(MMScrappedPaperView*)pageToDropScrap {
    CGFloat pageScale = pageToDropScrap.scale;
    CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1 / pageScale, 1 / pageScale);
    *scrapScaleInPage = scrap.scale;
    *scrapCenterInPage = scrap.center;
    *scrapScaleInPage = *scrapScaleInPage / pageScale;
    *scrapCenterInPage = [pageToDropScrap convertPoint:*scrapCenterInPage fromView:scrapContainer];
    *scrapCenterInPage = CGPointApplyAffineTransform(*scrapCenterInPage, reverseScaleTransform);
}

#pragma mark - MMStretchScrapGestureRecognizer

// this is called through the stretch of a
// scrap.
- (void)stretchScrapGesture:(MMStretchScrapGestureRecognizer*)gesture {
    if (gesture.scrap) {
        // don't allow animations during a stretch
        [gesture.scrap.layer removeAllAnimations];
        if (!CGPointEqualToPoint(gesture.scrap.layer.anchorPoint, CGPointZero)) {
            // the anchor point can get reset by the pan/pinch gesture ending,
            // so we need to force it back to our 0,0 for the stretch
            [UIView setAnchorPoint:CGPointMake(0, 0) forView:gesture.scrap];
        }
        // cancel any strokes etc happening with these touches
        [self isBeginningToPanAndScaleScrapWithTouches:gesture.validTouches];

        // generate the actual transform between the two quads
        gesture.scrap.layer.transform = CATransform3DConcat(startSkewTransform, [gesture skewTransform]);
    }
}

- (CGPoint)beginStretchForScrap:(MMScrapView*)scrap {
    if (![scrapContainer.subviews containsObject:scrap]) {
        MMPanAndPinchScrapGestureRecognizer* owningPan = panAndPinchScrapGesture.scrap == scrap ? panAndPinchScrapGesture : panAndPinchScrapGesture2;
        scrap.center = CGPointMake(owningPan.translation.x + owningPan.preGestureCenter.x,
                                   owningPan.translation.y + owningPan.preGestureCenter.y);
        scrap.scale = owningPan.preGestureScale * owningPan.scale * owningPan.preGesturePageScale;
        scrap.rotation = owningPan.rotation + owningPan.preGestureRotation;
        [scrapContainer addSubview:scrap];
    }

    // now, for our stretch gesture, we need the anchor point
    // to be at the 0,0 point of the scrap so that the transform
    // works properly to stretch the scrap.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];
    // the user has just now begun to hold a scrap
    // with four fingers and is stretching it.
    // set the anchor point to 0,0 for the skew transform
    // and keep our initial scale/rotate transform so
    // we can animate back to it when we're done
    scrap.selected = YES;
    startSkewTransform = scrap.layer.transform;

    //
    // keep the pan gestures alive, just pause them from
    // updating until after the stretch gesture so we can
    // handoff the newly stretched/moved/adjusted scrap
    // seemlessly
    [panAndPinchScrapGesture pause];
    [panAndPinchScrapGesture2 pause];
    return [scrap convertPoint:scrap.bounds.origin toView:self.visibleStackHolder];
}

// the stretch failed or ended before splitting, so give
// the pan gesture back it's scrap if its still alive
- (void)endStretchWithoutSplittingScrap:(MMScrapView*)scrap atNormalPoint:(CGPoint)np {
    // [stretchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:stretchScrapGesture.validTouches]];

    // check the gestures first to see if they're still alive,
    // and give the scrap back if possible.
    NSArray* validStretchTouches = [stretchScrapGesture validTouches];
    if (panAndPinchScrapGesture.scrap == scrap && [validStretchTouches count] >= 2) {
        // gesture 1 owns it, so give it back and turn gesture 2 back on
        // [panAndPinchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture.validTouches]];
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:[validStretchTouches asSet]];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture withTouches:validStretchTouches withAnchor:np];
        [panAndPinchScrapGesture2 begin];
    } else if (panAndPinchScrapGesture2.scrap == scrap && [validStretchTouches count] >= 2) {
        // gesture 2 owns it, so give it back and turn gesture 1 back on
        // [panAndPinchScrapGesture2 say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture2.validTouches]];
        [panAndPinchScrapGesture relinquishOwnershipOfTouches:[validStretchTouches asSet]];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture2 withTouches:validStretchTouches withAnchor:np];
        [panAndPinchScrapGesture begin];
    } else if ([validStretchTouches count] >= 2) {
        // neither has a scrap, but i have at least 2 touches to give away
        // gesture 1 owns it, so give it back and turn gesture 2 back on
        // [panAndPinchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture.validTouches]];
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:[validStretchTouches asSet]];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture withTouches:validStretchTouches withAnchor:np];
        [panAndPinchScrapGesture2 begin];
    } else {
        // DebugLog(@"original properties was %@ or %@", stretchScrapGesture.startingPageForScrap, stretchScrapGesture.startingScrapProperties);

        // neither has a scrap, and i don't have enough touches to give it away
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:[validStretchTouches asSet]];
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:[validStretchTouches asSet]];
        // otherwise, unpause both gestures and just
        // put the scrap back into the page
        [panAndPinchScrapGesture begin];
        [panAndPinchScrapGesture2 begin];

        scrap.layer.transform = startSkewTransform;
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:scrap];
        // kill highlight since it's not being held
        scrap.selected = NO;

        // find the page that we'll drop the scrap on
        MMUndoablePaperView* page = [self.visibleStackHolder peekSubview];
        if ([self.visibleStackHolder peekSubview].scrapsOnPaperState != scrap.state.scrapsOnPaperState) {
            // page doesn't own the scrap,
            // so we need to clone it to the new page
            // and update their undo stacks
            MMScrapView* clonedScrap = [self cloneScrap:scrap toPage:page];
            [page addUndoItemForAddedScrap:clonedScrap];

            // now update the undo stack of the owning page
            [scrap removeFromSuperview];
            [stretchScrapGesture.startingPageForScrap addUndoItemForRemovedScrap:scrap withProperties:stretchScrapGesture.startingScrapProperties];
        } else if (![[self.visibleStackHolder peekSubview].scrapsOnPaperState isScrapVisible:scrap]) {
            // the scrap was dropped by the stretch gesture,
            // so just add it back to the top page
            [page.scrapsOnPaperState showScrap:scrap];
            [page addUndoItemForScrap:scrap thatMovedFrom:stretchScrapGesture.startingScrapProperties to:[scrap propertiesDictionary]];
            [page saveToDisk:nil];
        }
    }
}

// this is a helper method to give a scrap back to a particular
// pan gesture. this should trigger any animations necessary
// on the scrap, and facilitate the transition from the possibly
// stretched transform of the scrap back to it's pre-stretched
// transform.
- (void)sendStretchedScrap:(MMScrapView*)scrap toPanGesture:(MMPanAndPinchScrapGestureRecognizer*)panScrapGesture withTouches:(NSArray*)touches withAnchor:(CGPoint)scrapAnchor {
    if ([touches count] < 2) {
        @throw [NSException exceptionWithName:@"NotEnoughTouchesForPan" reason:@"streching a scrap ended, but doesn't have enough touches to give back to a pan gesture" userInfo:nil];
    }


    // bless the touches so that the pan gesture
    // can pick them up
    [panScrapGesture forceBlessTouches:[NSSet setWithArray:touches] forScrap:scrap];

    // now that we've calcualted the current position for our
    // reference anchor point, we should now adjust our anchor
    // back to 0,0 during the next transforms to bounce
    // the scrap back to its new place.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];
    scrap.layer.transform = startSkewTransform;

    // find out where the location should be inside the page
    // for the input two (at most) touches
    MMScrappedPaperView* page = [self.visibleStackHolder peekSubview];
    CGPoint locationInPage = AveragePoints([[touches objectAtIndex:0] locationInView:page],
                                           [[touches objectAtIndex:1] locationInView:page]);

    // by setting the anchor point, the .center property will
    // automaticaly align the locationInPage to scrapAnchor
    [UIView setAnchorPoint:scrapAnchor forView:scrap];
    scrap.center = CGPointMake(locationInPage.x, locationInPage.y);
    if ([panScrapGesture begin]) {
        // if the pan gesture picked up the scrap,
        // then set it as still selected
        scrap.selected = YES;
    } else {
        // reset our anchor to the scrap center if a pan
        // isn't going to take over
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:scrap];
        // kill highlight since it's not being held
        scrap.selected = NO;
    }
}

// time to duplicate the scraps! it's been pulled into two pieces
- (void)endStretchBySplittingScrap:(MMScrapView*)scrap toTouches:(NSOrderedSet*)touches1 atNormalPoint:(CGPoint)np1
                        andTouches:(NSOrderedSet*)touches2
                     atNormalPoint:(CGPoint)np2 {
    // save the gestures to local variables.
    // this will let us make sure the input scrap stays with its
    // current gesture, if any
    MMPanAndPinchScrapGestureRecognizer* panScrapGesture1 = panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panScrapGesture2 = panAndPinchScrapGesture2;

    if (panAndPinchScrapGesture2.scrap == scrap) {
        // a gesture already owns that scrap, so let it keep it.
        // this will let the startingPageForScrap property
        // remain the same for the gesture, so the scrap won't
        // get accidentally assigned to the wrong page.
        //
        // to make sure everything still gets the right touches
        // at the right locations, i need to swap all inputs
        panScrapGesture1 = panAndPinchScrapGesture2;
        panScrapGesture2 = panAndPinchScrapGesture;
        NSOrderedSet* t = touches1;
        touches1 = touches2;
        touches2 = t;
        CGPoint tnp = np1;
        np1 = np2;
        np2 = tnp;
    }

    [panScrapGesture1 relinquishOwnershipOfTouches:[touches2 set]];
    [panScrapGesture2 relinquishOwnershipOfTouches:[touches1 set]];

    [self sendStretchedScrap:scrap toPanGesture:panScrapGesture1 withTouches:[touches1 array] withAnchor:np1];

    // next, add the new scrap to the same page as the stretched scrap
    MMUndoablePaperView* page = [self.visibleStackHolder peekSubview];
    MMScrapView* clonedScrap = [self cloneScrap:scrap toPage:page];

    // move it to the new gesture location under it's scrap
    CGPoint p1 = [[touches2 objectAtIndex:0] locationInView:self];
    CGPoint p2 = [[touches2 objectAtIndex:1] locationInView:self];
    clonedScrap.center = AveragePoints(p1, p2);

    [page addUndoItemForAddedScrap:clonedScrap];

    // hand the cloned scrap to the pan scrap gesture
    panScrapGesture2.scrap = clonedScrap;

    // time to reset the gesture for the cloned scrap
    // now the scrap is in the right place, so hand it off to the pan gesture
    [self sendStretchedScrap:clonedScrap toPanGesture:panScrapGesture2 withTouches:[touches2 array] withAnchor:np2];

    if (!panScrapGesture1.scrap || !panScrapGesture2.scrap) {
        DebugLog(@"ending scrap gesture w/o holding scrap");

        @throw [NSException exceptionWithName:@"DroppedSplitScrap" reason:@"split scrap was dropped by pan gestures" userInfo:nil];
    }

    [[Mixpanel sharedInstance] track:kMPEventCloneScrap];

    // now that the scrap is where it should be,
    // and contains its background, etc, then
    // save everything
    [page saveToDisk:nil];
}


#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

- (NSArray*)scrapsToPan {
    if ([_fromLeftBezelGesture isActivelyBezeling]) {
        return [[[self.bezelStackHolder peekSubview] scrapsOnPaper] arrayByAddingObjectsFromArray:scrapContainer.subviews];
    }
    return [[[self.visibleStackHolder peekSubview] scrapsOnPaper] arrayByAddingObjectsFromArray:scrapContainer.subviews];
}

- (BOOL)panScrapRequiresLongPress {
    return rulerButton.selected;
}

- (BOOL)isAllowedToPan {
    if ([_fromRightBezelGesture isActivelyBezeling] || [_fromLeftBezelGesture isActivelyBezeling]) {
        // not allowed to pan a page if we're
        // bezeling
        return NO;
    }
    if ([[MMPalmGestureRecognizer sharedInstance] hasSeenPalmDuringTouchSession]) {
        return NO;
    }

    return handButton.selected;
}

- (BOOL)isAllowedToBezel {
    return [super isAllowedToBezel] && ![[MMPalmGestureRecognizer sharedInstance] hasSeenPalmDuringTouchSession];
}

- (BOOL)allowsHoldingScrapsWithTouch:(UITouch*)touch {
    if ([_fromLeftBezelGesture isActivelyBezeling]) {
        return [touch locationInView:self.bezelStackHolder].x > 0;
    } else if ([_fromRightBezelGesture isActivelyBezeling]) {
        return [touch locationInView:self.bezelStackHolder].x < 0;
    }
    return YES;
}

- (CGFloat)topVisiblePageScaleForScrap:(MMScrapView*)scrap {
    if ([scrapContainer.subviews containsObject:scrap]) {
        return 1;
    } else {
        return [self.visibleStackHolder peekSubview].scale;
    }
}

- (CGPoint)convertScrapCenterToScrapContainerCoordinate:(MMScrapView*)scrap {
    CGPoint scrapCenter = scrap.center;
    if ([scrapContainer.subviews containsObject:scrap]) {
        return scrapCenter;
    } else {
        MMPaperView* pageHoldingScrap = [self.visibleStackHolder peekSubview];
        if ([_fromLeftBezelGesture isActivelyBezeling]) {
            pageHoldingScrap = [self.bezelStackHolder peekSubview];
        }
        CGFloat pageScale = pageHoldingScrap.scale;
        // because the page uses a transform to scale itself, the scrap center will always
        // be in page scale = 1.0 form. if the user picks up a scrap while also scaling the page,
        // then we need to transform that coordinate into the visible scale of the zoomed page.
        scrapCenter = CGPointApplyAffineTransform(scrapCenter, CGAffineTransformMakeScale(pageScale, pageScale));
        // now that the coordinate is in the visible scale, we can convert that directly to the
        // scapContainer's coodinate system
        return [pageHoldingScrap convertPoint:scrapCenter toView:scrapContainer];
    }
}

- (MMUndoablePaperView*)owningPageForScrap:(MMScrapView*)scrap {
    return (MMUndoablePaperView*)scrap.state.scrapsOnPaperState.delegate;
}

#pragma mark - PolygonToolDelegate

// when scissors complete, i need to drop all held scraps
- (void)finishShapeWithTouch:(UITouch*)touch withTool:(PolygonTool*)tool {
    // only cancel scrap gestures
    [panAndPinchScrapGesture cancel];
    [panAndPinchScrapGesture2 cancel];
    [stretchScrapGesture cancel];
    // now cut with scissors
    [super finishShapeWithTouch:touch withTool:tool];
}

#pragma mark - MMPaperViewDelegate

- (CGRect)isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches {
    CGRect ret = [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
    if (panAndPinchScrapGesture.state == UIGestureRecognizerStateBegan) {
        panAndPinchScrapGesture.state = UIGestureRecognizerStateChanged;
    }
    if (panAndPinchScrapGesture2.state == UIGestureRecognizerStateBegan) {
        panAndPinchScrapGesture2.state = UIGestureRecognizerStateChanged;
    }
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];

    return ret;
}

- (void)finishedPanningAndScalingPage:(MMPaperView*)page intoBezel:(MMBezelDirection)direction fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame {
    [super finishedPanningAndScalingPage:page intoBezel:direction fromFrame:fromFrame toFrame:toFrame];
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];
}

- (void)setButtonsVisible:(BOOL)visible animated:(BOOL)animated {
    [self.stackDelegate didAskToChangeButtonOpacity:visible animated:animated forStack:self.uuid];
    [super setButtonsVisible:visible animated:animated];
}


- (void)isBeginningToPanAndScaleScrapWithTouches:(NSArray*)touches {
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for (UITouch* touch in touches) {
        [[JotStrokeManager sharedInstance] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }
}

- (void)finishedPanningAndScalingScrap:(MMScrapView*)scrap {
    // save page if we're not holding any scraps
    if (!panAndPinchScrapGesture.scrap && !panAndPinchScrapGesture2.scrap && !stretchScrapGesture.scrap) {
        [[self.visibleStackHolder peekSubview] saveToDisk:nil];
    }
}

- (MMScrapsInBezelContainerView*)bezelContainerView {
    return self.stackDelegate.bezelScrapContainer;
}

- (void)didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk {
    [self.stackDelegate didExportPage:page toZipLocation:fileLocationOnDisk];
}

- (void)didFailToExportPage:(MMPaperView*)page {
    [self.stackDelegate didFailToExportPage:page];
}

- (void)isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk {
    [self.stackDelegate isExportingPage:page withPercentage:percentComplete toZipLocation:fileLocationOnDisk];
}

#pragma mark - MMScrapViewOwnershipDelegate

- (MMScrapView*)scrapForUUIDIfAlreadyExistsInOtherContainer:(NSString*)scrapUUID {
    // try to load a scrap from the bezel sidebar if possible,
    // otherwise our scrap state will load it
    MMScrapView* scrapOwnedByBezel = [self.stackDelegate.bezelScrapContainer.sidebarScrapState scrapForUUID:scrapUUID];
    //    MMScrapView* scrapOwnedByPan1 = scr

    MMScrapView* scrapOwnedByPan1 = panAndPinchScrapGesture.scrap;
    MMScrapView* scrapOwnedByPan2 = panAndPinchScrapGesture2.scrap;

    //    panAndPinchScrapGesture
    if (scrapOwnedByBezel) {
        return scrapOwnedByBezel;
    } else if ([scrapOwnedByPan1.uuid isEqualToString:scrapUUID]) {
        return scrapOwnedByPan1;
    } else if ([scrapOwnedByPan2.uuid isEqualToString:scrapUUID]) {
        return scrapOwnedByPan2;
    }
    return nil;
}

#pragma mark - MMGestureTouchOwnershipDelegate

- (void)ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture {
    [super ownershipOfTouches:touches isGesture:gesture];
    if ([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]] ||
        [gesture isKindOfClass:[MMStretchScrapGestureRecognizer class]]) {
        // only notify of our own gestures, super will handle its own
        [[self.visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
    [stretchScrapGesture ownershipOfTouches:touches isGesture:gesture];
}

#pragma mark - Page Loading and Unloading

- (void)willChangeTopPageTo:(MMPaperView*)page {
    [super willChangeTopPageTo:page];
    [[[MMPageCacheManager sharedInstance] currentEditablePage] saveToDisk:nil];
}


#pragma mark - Long Press Scrap

- (void)didLongPressPage:(MMPaperView*)page withTouches:(NSSet*)touches {
    // if we're in ruler mode, then
    // let the pan scrap gestures know that they can move the scrap
    if ([self panScrapRequiresLongPress]) {
        //
        // if a long press happens, give the touches to
        // whichever scrap pan gesture doesn't have a scrap
        if (!panAndPinchScrapGesture.scrap) {
            [panAndPinchScrapGesture blessTouches:touches];
        } else {
            [panAndPinchScrapGesture2 blessTouches:touches];
        }
        [stretchScrapGesture blessTouches:touches];
    }
}

#pragma mark - MMScrapSidebarViewDelegate

- (void)showScrapSidebar:(UIButton*)button {
    // showing the actual sidebar is handled inside
    // the MMScrapSlidingSidebarView, which adds
    // its own target to the button
    [self cancelAllGestures];
}

- (void)willAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    CheckMainThread;
    isAnimatingScrapToOrFromSidebar = YES;
}

- (void)didAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    CheckMainThread;
    [self.stackDelegate.bezelScrapContainer saveScrapContainerToDisk];
    isAnimatingScrapToOrFromSidebar = NO;
}

- (void)willRemoveView:(UIView<MMUUIDView>*)view fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    CheckMainThread;
    isAnimatingScrapToOrFromSidebar = YES;
}

// @param originalScrap this is the scrap that is asking to be added to this page,
//        but it might belong to a different page. if that's the case, we'll
//        need to clone this scrap onto our page and then give the original to
//        the trashmanager to deal with.
// returns the page that the scrap was added to
- (void)didRemoveView:(MMScrapView*)originalScrap atIndex:(NSUInteger)index hadProperties:(BOOL)hadProperties fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    // first, find the page to add the scrap to.
    // this will check visible + bezelled pages to see
    // which page should get the scrap, and it'll tell us
    // the center/scale to use
    CGPoint center;
    CGFloat scale = 1;
    MMUndoablePaperView* page = [self pageWouldDropScrap:originalScrap atCenter:&center andScale:&scale];

    [originalScrap blockToFireWhenStateLoads:^{
        CheckMainThread;
        // we're only allowed to add scraps to a page
        // when their state is loaded, so make sure
        // we have their state loading
        MMScrapView* scrapToAddToPage = originalScrap;
        if (originalScrap.state.scrapsOnPaperState != page.scrapsOnPaperState) {
            DebugLog(@"looking at2 %p", originalScrap);
            DebugLog(@"cloned from %p to %p", originalScrap.state.scrapsOnPaperState, page.scrapsOnPaperState);
            DebugLog(@"loaded: %d", originalScrap.state.isScrapStateLoaded);
            DebugLog(@"superview: %p", originalScrap.superview);
            [scrapContainer addSubview:originalScrap];
            scrapToAddToPage = [self cloneScrap:originalScrap toPage:page];
            [originalScrap removeFromSuperview];

            // check the original page of the scrap
            // and see if it has any reference to this
            // scrap. if its undo stack doesn't hold any
            // reference, then we should trigger deleting
            // it's old assets
            [[MMTrashManager sharedInstance] deleteScrap:originalScrap.uuid inScrapCollectionState:originalScrap.state.scrapsOnPaperState];
        }
        // ok, done, just set it
        if (index == NSNotFound) {
            [page.scrapsOnPaperState showScrap:scrapToAddToPage];
        } else {
            [page.scrapsOnPaperState showScrap:scrapToAddToPage atIndex:index];
        }
        scrapToAddToPage.center = center;
        scrapToAddToPage.scale = scale;
        [page saveToDisk:nil];
        [self.stackDelegate.bezelScrapContainer saveScrapContainerToDisk];

        isAnimatingScrapToOrFromSidebar = NO;
    }];

    [originalScrap blockToFireWhenStateLoads:^{
        if (!hadProperties) {
            DebugLog(@"tapped on scrap from sidebar. should add undo item to page %@", page.uuid);
            [page addUndoItemForMostRecentAddedScrapFromBezelFromScrap:originalScrap];
        } else {
            DebugLog(@"scrap added from undo item, don't add new undo item");
        }
    }];
}

- (MMScrappedPaperView*)pageForUUID:(NSString*)uuid {
    NSMutableArray* allPages = [NSMutableArray arrayWithArray:self.visibleStackHolder.subviews];
    [allPages addObjectsFromArray:[self.bezelStackHolder.subviews copy]];
    [allPages addObjectsFromArray:[self.hiddenStackHolder.subviews copy]];
    return [[allPages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
        return [[evaluatedObject uuid] isEqualToString:uuid];
    }]] firstObject];
}

- (CGPoint)positionOnScreenToScaleViewTo:(UIView<MMUUIDView>*)view fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    return [self.visibleStackHolder center];
}

- (CGFloat)scaleOnScreenToScaleViewTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    return originalScale * [self.visibleStackHolder peekSubview].scale;
}


#pragma mark - List View

- (void)isBeginningToScaleReallySmall:(MMPaperView*)page {
    if (panAndPinchScrapGesture.scrap) {
        [panAndPinchScrapGesture cancel];
    }
    if (panAndPinchScrapGesture2.scrap) {
        [panAndPinchScrapGesture2 cancel];
    }
    [panAndPinchScrapGesture setEnabled:NO];
    [panAndPinchScrapGesture2 setEnabled:NO];
    [super isBeginningToScaleReallySmall:page];
}

- (void)cancelledScalingReallySmall:(MMPaperView*)page {
    [panAndPinchScrapGesture setEnabled:YES];
    [panAndPinchScrapGesture2 setEnabled:YES];
    [super cancelledScalingReallySmall:page];
}


- (void)finishedScalingReallySmall:(MMPaperView*)page animated:(BOOL)animated {
    if (panAndPinchScrapGesture.scrap) {
        [panAndPinchScrapGesture cancel];
    }
    if (panAndPinchScrapGesture2.scrap) {
        [panAndPinchScrapGesture2 cancel];
    }
    [panAndPinchScrapGesture setEnabled:NO];
    [panAndPinchScrapGesture2 setEnabled:NO];
    [super finishedScalingReallySmall:page animated:(BOOL)animated];
}

- (void)finishedScalingBackToPageView:(MMPaperView*)page {
    [panAndPinchScrapGesture setEnabled:YES];
    [panAndPinchScrapGesture2 setEnabled:YES];
    [super finishedScalingBackToPageView:page];
}


#pragma mark - MMStretchScrapGestureRecognizerDelegate

// return all touches that fall within the input scrap's boundary
// and don't fall within any scrap above the input scrap
- (NSSet*)setOfTouchesFrom:(NSOrderedSet*)touches inScrap:(MMScrapView*)scrap {
    return nil;
}

#pragma mark - MMRotationManagerDelegate

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading {
    [super didUpdateAccelerometerWithReading:currentRawReading];
    [NSThread performBlockOnMainThread:^{
        [self.stackDelegate.bezelScrapContainer didUpdateAccelerometerWithReading:currentRawReading];
    }];
}

- (void)didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel {
    if (1 - ABS(zAccel) > .03) {
        [NSThread performBlockOnMainThread:^{
            [super didUpdateAccelerometerWithReading:currentRawReading];
            [[self.visibleStackHolder peekSubview] didUpdateAccelerometerWithRawReading:currentRawReading];
        }];
    }
}

- (void)didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient {
    // noop
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    // noop
}

#pragma mark = Saving and Editing

- (void)didSavePage:(MMPaperView*)page {
    [super didSavePage:page];
    if (wantsExport == page) {
        wantsExport = nil;
        [self shareButtonTapped:nil];
    }
}


#pragma mark - Clone Scrap

/**
 * this will clone a scrap and also clone it's contents
 * the scrap to be cloned must be in our scrapContainer,
 * and the cloned scrap will be put in the scrapContainer
 * as well, exactly overlapping it
 *
 * the new cloned scrap is allowed to be added to our
 * scrap container, its just not allowed to be added to
 * any pages scrap container besides its own
 */
- (MMScrapView*)cloneScrap:(MMScrapView*)scrap toPage:(MMScrappedPaperView*)page {
    CheckMainThread;

    if (![scrap.state isScrapStateLoaded]) {
        // force loading the scrap immediately
        [scrap.state loadScrapStateAsynchronously:NO];
    }
    if (![scrapContainer.subviews containsObject:scrap]) {
        @throw [NSException exceptionWithName:@"CloneScrapException" reason:@"Page asked to clone scrap and doesn't own it" userInfo:nil];
    }
    // we need to send in scale 1.0 because the *path* scale we're sending in is for the 1.0 scaled path.
    // if we sent the scale into this method, it would assume that the input path was *already at* the input
    // scale, so it would transform the path to a 1.0 scale before adding the scrap. this would result in incorrect
    // resolution for the new scrap. so set the rotation to make sure we're getting the smallest bounding
    // box, and we'll set the scrap's scale to match after we add it to the page.

    BOOL needsStateLoading = ![page.scrapsOnPaperState isStateLoaded];
    __block MMScrapView* clonedScrap = nil;

    void (^block)() = ^{
        CheckMainThread;

        clonedScrap = [page.scrapsOnPaperState addScrapWithPath:[scrap.bezierPath copy] andRotation:scrap.rotation andScale:1.0];
        clonedScrap.scale = scrap.scale;
        clonedScrap.backgroundColor = scrap.backgroundColor;

        @synchronized(scrapContainer) {
            // make sure scraps are in the same coordinate space
            [scrapContainer addSubview:clonedScrap];
        }

        // next match it's location exactly on top of the original scrap:
        [UIView setAnchorPoint:scrap.layer.anchorPoint forView:clonedScrap];
        clonedScrap.center = scrap.center;

        // next, clone the contents onto the new scrap. at this point i have a duplicate scrap
        // but it's in the wrong place.
        [clonedScrap stampContentsFrom:scrap.state.drawableView];

        // clone background contents too
        [clonedScrap setBackgroundView:[scrap.backgroundView duplicateFor:clonedScrap.state]];

        // set the scrap anchor to its center
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:clonedScrap];

        [page.scrapsOnPaperState showScrap:clonedScrap];
    };

    if (needsStateLoading) {
        DebugLog(@"needs loading");
        [page performBlockForUnloadedScrapStateSynchronously:block andImmediatelyUnloadState:(page != [self.visibleStackHolder peekSubview]) andSavePaperState:YES];
    } else {
        DebugLog(@"doesn't need loading");
        block();
    }

    return clonedScrap;
}


#pragma mark - Hit Test

// MMEditablePaperStackView calls this method to check
// if the sidebar buttons should take priority over anything else
- (BOOL)shouldPrioritizeSidebarButtonsForTaps {
    return ![self.stackDelegate.backgroundStyleSidebar isVisible] && ![self.stackDelegate.importImageSidebar isVisible] && ![self.stackDelegate.sharePageSidebar isVisible] && [super shouldPrioritizeSidebarButtonsForTaps];
}

#pragma mark - Check for Active Gestures

- (BOOL)isActivelyGesturing {
    return [super isActivelyGesturing] || panAndPinchScrapGesture.scrap || panAndPinchScrapGesture2.scrap || stretchScrapGesture.scrap || isAnimatingScrapToOrFromSidebar;
}

- (UIView*)blurViewForSidebar:(MMFullScreenSidebarContainingView*)sidebar {
    return [self.visibleStackHolder peekSubview];
}

#pragma mark - MMShareSidebarDelegate

- (ExportRotation)idealExportRotation {
    return [[self.visibleStackHolder peekSubview] idealExportRotation];
}

- (void)setIdealExportRotation:(ExportRotation)idealExportRotation {
    [[self.visibleStackHolder peekSubview] setIdealExportRotation:idealExportRotation];
}

- (void)exportVisiblePageToImage:(void (^)(NSURL*))completionBlock {
    [[self.visibleStackHolder peekSubview] exportVisiblePageToImage:completionBlock];
}

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    [[self.visibleStackHolder peekSubview] exportVisiblePageToPDF:completionBlock];
}

- (void)mayShare:(MMAbstractShareItem*)shareItem {
    // noop
}

- (void)wontShare:(MMAbstractShareItem*)shareItem {
    // noop
}

- (void)didShare:(MMAbstractShareItem*)shareItem {
    // noop
}

#pragma mark - Import

- (BOOL)importAndShowPage:(MMExportablePaperView*)page {
    if (![super importAndShowPage:page]) {
        [[MMPageCacheManager sharedInstance] mayChangeTopPageTo:page];
        [[MMPageCacheManager sharedInstance] willChangeTopPageTo:page];
        [[NSThread mainThread] performBlock:^{
            [self forceScrapToScrapContainerDuringGesture];
            if ([_setOfPagesBeingPanned count]) {
                DebugLog(@"adding new page, but pages are being panned.");
                for (MMPaperView* page in [_setOfPagesBeingPanned copy]) {
                    [page cancelAllGestures];
                }
            }
            [[self.visibleStackHolder peekSubview] cancelAllGestures];
            [self.hiddenStackHolder pushSubview:page];
            [[self.visibleStackHolder peekSubview] enableAllGestures];
            [self popTopPageOfHiddenStack];
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
            [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedPage: @(YES) }];
        } afterDelay:.1];
    }
    return YES;
}

#pragma mark - Resign Active

- (void)willResignActive {
    MMUndoablePaperView* currentEditablePage = [[MMPageCacheManager sharedInstance] currentEditablePage];

    // introspect the page to see if it or any of its
    // scraps are still loading OpenGL content
    BOOL (^isPageLoadingHuh)(MMUndoablePaperView*) = ^(MMUndoablePaperView* page) {
        __block BOOL isAnyStateLoading = [currentEditablePage isStateLoading];
        [[currentEditablePage scrapsOnPaper] enumerateObjectsUsingBlock:^(MMScrapView* obj, NSUInteger idx, BOOL* stop) {
            isAnyStateLoading = isAnyStateLoading || [[obj state] isScrapStateLoading];
        }];
        return isAnyStateLoading;
    };

    // we'll wait around if:
    // 1. our top page has pending edits to save
    // 2. our top page is still loading in content
    // 3. there are ny OpenGL objects sitting in the trash
    DebugLog(@" - checking if page is ready to background: saving? %d  loading? %d  trash? %d", [currentEditablePage hasEditsToSave], isPageLoadingHuh(currentEditablePage), (int)[[JotTrashManager sharedInstance] numberOfItemsInTrash]);

    // we need to delay resigning active if our top page
    // is loading or saving any OpenGL content. Once we
    // leave this method, all our OpenGL calls will crash
    // the app, so we need to try our best to wrap up before
    // then.
    if ([currentEditablePage hasEditsToSave] || [[JotTrashManager sharedInstance] numberOfItemsInTrash] || isPageLoadingHuh(currentEditablePage) || ![[MMPageCacheManager sharedInstance] isEditablePageStable]) {
        MMStopWatch* stopwatch = [[MMStopWatch alloc] init];
        [stopwatch start];

        // if we're in here, then our page has to either load or save
        // some content. We're going to use a custom MMMainOperationQueue
        // that will let other threads send blocks to the main thread
        // without enqueuing them into the dispatch_get_main_queue().
        //
        // regardless of what happens, we'll only wait here for 7 seconds
        // to prevent us from being killed by the watchdog.
        while (([currentEditablePage hasEditsToSave] || isPageLoadingHuh(currentEditablePage) || [[JotTrashManager sharedInstance] numberOfItemsInTrash] || ![[MMPageCacheManager sharedInstance] isEditablePageStable]) && [stopwatch read] < 7) {
            // fire any timers that would've been triggered if this was a normal run loop
            [[MMWeakTimer allWeakTimers] makeObjectsPerformSelector:@selector(fireIfNeeded)];
            // now run any blocks that were sent to the main thread from background threads
            if ([[MMMainOperationQueue sharedQueue] pendingBlockCount]) {
                while ([[MMMainOperationQueue sharedQueue] pendingBlockCount]) {
                    [[MMMainOperationQueue sharedQueue] tick];
                }
            } else {
                // we didn't have any blocks to run, so just
                // wait here until either .2s is up or a background
                // thread signals us with a new block to run
                [[MMMainOperationQueue sharedQueue] waitFor:0.2];
            }
            DebugLog(@" - exit status: %d %d %d %d", [currentEditablePage hasEditsToSave], isPageLoadingHuh(currentEditablePage), (int)[[JotTrashManager sharedInstance] numberOfItemsInTrash], ![[MMPageCacheManager sharedInstance] isEditablePageStable]);
        }
        DebugLog(@" - completed save in %.2fs", [stopwatch read]);

        BOOL topIsLoadedAndEditable = [[MMPageCacheManager sharedInstance] isEditablePageStable];
        DebugLog(@" - top is editable and loaded? %d", topIsLoadedAndEditable);
    }
    DebugLog(@"stack: willResignActive end");
}

- (void)didEnterBackground {
    // noop
}

@end
