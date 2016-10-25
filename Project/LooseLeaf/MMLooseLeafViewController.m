//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMLooseLeafViewController.h"
#import "MMShadowManager.h"
#import "MMEditablePaperView.h"
#import "MMDebugDrawView.h"
#import "MMInboxManager.h"
#import "MMMemoryProfileView.h"
#import "Mixpanel.h"
#import "MMMemoryManager.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMDeletePageSidebarController.h"
#import "MMPhotoManager.h"
#import "MMTutorialStackView.h"
#import "MMCloudKitImportExportView.h"
#import "MMPaperStackViewDelegate.h"
#import "MMStackControllerView.h"
#import "MMTextButton.h"
#import "MMAllStacksManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMShareSidebarContainerView.h"
#import "NSArray+Map.h"
#import "MMTutorialView.h"
#import "MMTutorialManager.h"
#import "MMTutorialViewDelegate.h"
#import "MMPalmGestureRecognizer.h"
#import "MMRotatingBackgroundView.h"
#import "MMTrashManager.h"
#import "MMAbstractShareItem.h"
#import "MMReleaseNotesViewController.h"
#import "MMReleaseNotesView.h"
#import "MMFeedbackViewController.h"
#import "UIApplication+Version.h"
#import "MMAppDelegate.h"
#import "MMPresentationWindow.h"
#import "MMTutorialViewController.h"
#import "Constants.h"
#import "MMMarkdown.h"
#import "MMFeedbackViewController.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMPagesInBezelContainerView.h"


@interface MMLooseLeafViewController () <MMTutorialStackViewDelegate, MMPageCacheManagerDelegate, MMInboxManagerDelegate, MMCloudKitManagerDelegate, MMGestureTouchOwnershipDelegate, MMRotationManagerDelegate, MMImageSidebarContainerViewDelegate, MMShareSidebarDelegate, MMScrapSidebarContainerViewDelegate, MMPagesSidebarContainerViewDelegate>

@end


@implementation MMLooseLeafViewController {
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;
    MMCloudKitImportExportView* cloudKitExportView;

    MMStackControllerView* listOfStacksView;

    // image picker sidebar
    MMImageSidebarContainerView* importImageSidebar;

    // share sidebar
    MMShareSidebarContainerView* sharePageSidebar;

    NSMutableDictionary* stackViewsByUUID;

    // tutorials
    MMTutorialViewController* tutorialViewController;
    MMReleaseNotesViewController* releaseNotesViewController;
    MMFeedbackViewController* feedbackViewController;
    UIView* backdrop;

    // make sure to only check to show release notes once per launch
    BOOL mightShowReleaseNotes;

    // the scrap button that shows the count
    // in the right sidebar
    MMScrapsInBezelContainerView* bezelScrapContainer;

    MMPagesInBezelContainerView* bezelPagesContainer;

    MMPaperView* pageInActiveSidebarAnimation;

    UIView* stackContainerView;
}

- (id)init {
    if (self = [super init]) {
        mightShowReleaseNotes = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pageCacheManagerDidLoadPage)
                                                     name:kPageCacheManagerHasLoadedAnyPage
                                                   object:[MMPageCacheManager sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialShouldOpen:) name:kTutorialStartedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialShouldClose:) name:kTutorialClosedNotification object:nil];

        stackViewsByUUID = [NSMutableDictionary dictionary];

        [MMPageCacheManager sharedInstance].delegate = self;
        [MMInboxManager sharedInstance].delegate = self;
        [MMCloudKitManager sharedManager].delegate = self;
        [[MMRotationManager sharedInstance] setDelegate:self];


        // Do any additional setup after loading the view, typically from a nib.
        srand((uint)time(NULL));
        [[MMShadowManager sharedInstance] beginGeneratingShadows];

        self.view.opaque = YES;

        [self.view addSubview:[[MMRotatingBackgroundView alloc] initWithFrame:self.view.bounds]];

        deleteSidebar = [[MMDeletePageSidebarController alloc] initWithFrame:self.view.bounds andDarkBorder:NO];
        deleteSidebar.deleteCompleteBlock = ^(UIView* pageToDelete) {
            if ([pageToDelete isKindOfClass:[MMPaperView class]]) {
                // sanity check. only pages should be passed here in list view.
                // scraps are handled in a separate delete sidebar
                [[MMTrashManager sharedInstance] deletePage:(MMPaperView*)pageToDelete];
            }
        };
        [self.view addSubview:deleteSidebar.deleteSidebarBackground];

        stackContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:stackContainerView];


        // export icons will show here, below the sidebars but over the stacks
        cloudKitExportView = [[MMCloudKitImportExportView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:cloudKitExportView];
        // an extra view to help with animations
        MMUntouchableView* exportAnimationHelperView = [[MMUntouchableView alloc] initWithFrame:self.view.bounds];
        cloudKitExportView.animationHelperView = exportAnimationHelperView;
        [self.view addSubview:exportAnimationHelperView];

        [self.view addSubview:deleteSidebar.deleteSidebarForeground];


        // book keeping

        [[[Mixpanel sharedInstance] people] set:kMPNumberOfPages
                                             to:@([self numberOfPages])];
        NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[[Mixpanel sharedInstance] people] set:kMPPreferredLanguage
                                             to:language];
        [[[Mixpanel sharedInstance] people] setOnce:@{ kMPDidBackgroundDuringTutorial: @(NO),
                                                       kMPNewsletterStatus: @"Unknown",
                                                       kMPHasFinishedTutorial: @(NO),
                                                       kMPDurationWatchingTutorial: @(0),
                                                       kMPFirstLaunchDate: [NSDate date],
                                                       kMPHasAddedPage: @(NO),
                                                       kMPHasZoomedToList: @(NO),
                                                       kMPHasReorderedPage: @(NO),
                                                       kMPHasBookTurnedPage: @(NO),
                                                       kMPHasShakeToReorder: @(NO),
                                                       kMPHasBezelledScrap: @(NO),
                                                       kMPNumberOfPenUses: @(0),
                                                       kMPNumberOfEraserUses: @(0),
                                                       kMPNumberOfScissorUses: @(0),
                                                       kMPNumberOfRulerUses: @(0),
                                                       kMPNumberOfImports: @(0),
                                                       kMPNumberOfPhotoImports: @(0),
                                                       kMPNumberOfCloudKitImports: @(0),
                                                       kMPNumberOfPhotosTaken: @(0),
                                                       kMPNumberOfExports: @(0),
                                                       kMPNumberOfCloudKitExports: @(0),
                                                       kMPDurationAppOpen: @(0.0),
                                                       kMPNumberOfCrashes: @(0),
                                                       kMPDistanceDrawn: @(0.0),
                                                       kMPDistanceErased: @(0.0),
                                                       kMPNumberOfClippingExceptions: @(0.0),
                                                       kMPShareStatusCloudKit: kMPShareStatusUnknown,
                                                       kMPShareStatusFacebook: kMPShareStatusUnknown,
                                                       kMPShareStatusTwitter: kMPShareStatusUnknown,
                                                       kMPShareStatusEmail: kMPShareStatusUnknown,
                                                       kMPShareStatusSMS: kMPShareStatusUnknown,
                                                       kMPShareStatusTencentWeibo: kMPShareStatusUnknown,
                                                       kMPShareStatusSinaWeibo: kMPShareStatusUnknown,
        }];
        [[Mixpanel sharedInstance] flush];

        memoryManager = [[MMMemoryManager alloc] initWithDelegate:self];

        // Load the stack

        [self switchToStack:[[[MMAllStacksManager sharedInstance] stackIDs] firstObject]];

        // Image import sidebar
        importImageSidebar = [[MMImageSidebarContainerView alloc] initWithFrame:self.view.bounds forButton:currentStackView.insertImageButton animateFromLeft:YES];
        importImageSidebar.delegate = self;
        [importImageSidebar hide:NO onComplete:nil];
        [self.view addSubview:importImageSidebar];

        // Share sidebar
        [[NSThread mainThread] performBlock:^{
            // going to delay building this UI so we can startup faster
            sharePageSidebar = [[MMShareSidebarContainerView alloc] initWithFrame:self.view.bounds forButton:currentStackView.shareButton animateFromLeft:YES];
            sharePageSidebar.delegate = self;
            [sharePageSidebar hide:NO onComplete:nil];
            sharePageSidebar.shareDelegate = self;
            [self.view addSubview:sharePageSidebar];
        } afterDelay:1];

        // scrap sidebar
        CGRect frame = [self.view bounds];
        CGFloat rightBezelSide = frame.size.width - 100;
        CGFloat midPointY = (frame.size.height - 3 * 80) / 2;
        MMCountBubbleButton* countButton = [[MMCountBubbleButton alloc] initWithFrame:CGRectMake(rightBezelSide, midPointY - 60, 80, 80)];

        bezelScrapContainer = [[MMScrapsInBezelContainerView alloc] initWithFrame:frame andCountButton:countButton];
        bezelScrapContainer.delegate = self;
        bezelScrapContainer.bubbleDelegate = self;
        [self.view addSubview:bezelScrapContainer];

        [bezelScrapContainer loadFromDisk];

        // page sidebar

        frame = [self.view bounds];
        rightBezelSide = frame.size.width - 100;
        midPointY = (frame.size.height - 3 * 80) / 2;
        MMCountBubbleButton* countPagesButton = [[MMCountBubbleButton alloc] initWithFrame:CGRectMake(rightBezelSide, midPointY - 60, 80, 80)];

        bezelPagesContainer = [[MMPagesInBezelContainerView alloc] initWithFrame:frame andCountButton:countPagesButton];
        bezelPagesContainer.delegate = self;
        bezelPagesContainer.bubbleDelegate = self;
        [self.view addSubview:bezelPagesContainer];

        [bezelPagesContainer loadFromDisk];

        // Gesture Recognizers
        [self.view addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];
        [self.view addGestureRecognizer:[MMPalmGestureRecognizer sharedInstance]];
        [MMPalmGestureRecognizer sharedInstance].panDelegate = self;

        [[MMDrawingTouchGestureRecognizer sharedInstance] setTouchDelegate:self];
        [self.view addGestureRecognizer:[MMDrawingTouchGestureRecognizer sharedInstance]];

        // refresh button visibility after adding all our sidebars
        [currentStackView setButtonsVisible:[currentStackView buttonsVisible] animated:NO];

        // Debug

        //        MMMemoryProfileView* memoryProfileView = [[MMMemoryProfileView alloc] initWithFrame:self.view.bounds];
        //        memoryProfileView.memoryManager = memoryManager;
        //        memoryProfileView.hidden = YES;
        //
        //        [stackView setMemoryView:memoryProfileView];
        //        [self.view addSubview:memoryProfileView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pageCacheManagerDidLoadPage {
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPageCacheManagerHasLoadedAnyPage object:nil];
}

- (void)importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication {
    // ask the inbox manager to
    [[MMInboxManager sharedInstance] processInboxItem:url fromApp:(NSString*)sourceApplication];
}

- (void)printKeys:(NSDictionary*)dict atlevel:(NSInteger)level {
    NSString* space = @"";
    for (int i = 0; i < level; i++) {
        space = [space stringByAppendingString:@" "];
    }
    for (NSString* key in [dict allKeys]) {
        id obj = [dict objectForKey:key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self printKeys:obj atlevel:level + 1];
        } else {
            if ([obj isKindOfClass:[NSArray class]]) {
                DebugLog(@"%@ %@ - %@ [%lu]", space, key, [obj class], (unsigned long)[obj count]);
            } else {
                DebugLog(@"%@ %@ - %@", space, key, [obj class]);
            }
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (mightShowReleaseNotes) {
        mightShowReleaseNotes = NO;
        [self showReleaseNotesIfNeeded];
    }
}


#pragma mark - application state

- (void)willResignActive {
    DebugLog(@"telling stack to cancel all gestures");
    [currentStackView willResignActive];
    [currentStackView cancelAllGestures];
    [[currentStackView.visibleStackHolder peekSubview] cancelAllGestures];
}

- (void)didEnterBackground {
    [currentStackView didEnterBackground];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    //    DebugLog(@"dismissing view controller");
}

- (void)presentViewController:(UIViewController*)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    //    DebugLog(@"presenting view controller");
}

#pragma mark - MMPaperStackViewDelegate

- (void)animatingToListView {
    listOfStacksView.alpha = 1;
    [currentStackView setButtonsVisible:NO animated:NO];
}

- (void)animatingToPageView {
    listOfStacksView.alpha = 0;
    [currentStackView setButtonsVisible:YES animated:YES];
}

- (MMScrapsInBezelContainerView*)bezelScrapContainer {
    return bezelScrapContainer;
}

- (MMPagesInBezelContainerView*)bezelPagesContainer {
    return bezelPagesContainer;
}

- (MMImageSidebarContainerView*)importImageSidebar {
    return importImageSidebar;
}

- (MMShareSidebarContainerView*)sharePageSidebar {
    return sharePageSidebar;
}

- (void)didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk {
    [cloudKitExportView didExportPage:page toZipLocation:fileLocationOnDisk];
}

- (void)didFailToExportPage:(MMPaperView*)page {
    [cloudKitExportView didFailToExportPage:page];
}

- (void)isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk {
    [cloudKitExportView isExportingPage:page withPercentage:percentComplete toZipLocation:fileLocationOnDisk];
}

- (BOOL)isShowingAnyModal {
    return [self isShowingTutorial] || [self isShowingReleaseNotes] || [self isShowingReleaseNotes];
}

- (BOOL)isShowingTutorial {
    return tutorialViewController != nil;
}

- (BOOL)isShowingReleaseNotes {
    return releaseNotesViewController != nil;
}

- (BOOL)isShowingFeedbackForm {
    return feedbackViewController != nil;
}

- (void)didLoadStack:(MMPaperStackView*)stack {
    if (stackContainerView.hidden) {
        // now that we've loaded the app, we can show the stack view
    }
}

#pragma mark - MMTutorialStackViewDelegate

- (void)stackViewDidPressFeedbackButton:(MMTutorialStackView*)stackView {
    if ([self isShowingAnyModal]) {
        // tutorial is already showing, just return
        return;
    }

    backdrop = [[UIView alloc] initWithFrame:self.view.bounds];
    backdrop.backgroundColor = [UIColor colorWithWhite:.5 alpha:1];
    backdrop.alpha = 0;
    [self.view addSubview:backdrop];

    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];

    feedbackViewController = [[MMFeedbackViewController alloc] initWithCompletionBlock:^{
        [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
            feedbackViewController = nil;
        }];
        [UIView animateWithDuration:.3 animations:^{
            backdrop.alpha = 0;
        }];
    }];

    [presentationWindow.rootViewController presentViewController:feedbackViewController animated:YES completion:nil];

    [UIView animateWithDuration:.3 animations:^{
        backdrop.alpha = 1;
    }];
}

#pragma mark - MMStackControllerViewDelegate

- (void)addStack {
    NSString* stackID = [[MMAllStacksManager sharedInstance] createStack];
    [self switchToStack:stackID];
    [listOfStacksView reloadStackButtons];
}

- (void)switchToStack:(NSString*)stackUUID {
    MMTutorialStackView* aStackView = [self stackForUUID:stackUUID];

    [stackViewsByUUID enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, MMTutorialStackView* _Nonnull obj, BOOL* _Nonnull stop) {
        obj.hidden = ![key isEqualToString:aStackView.uuid];
    }];

    currentStackView = aStackView;

    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];

    cloudKitExportView.stackView = currentStackView;
    [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:currentStackView];

    [[MMPageCacheManager sharedInstance] willChangeTopPageTo:[[currentStackView visibleStackHolder] peekSubview]];
    [[MMPageCacheManager sharedInstance] didChangeToTopPage:[[currentStackView visibleStackHolder] peekSubview]];
}

- (void)deleteStack:(NSString*)stackUUID {
    NSInteger idx = [[[MMAllStacksManager sharedInstance] stackIDs] indexOfObject:stackUUID];
    if (stackViewsByUUID[stackUUID]) {
        [stackViewsByUUID[stackUUID] removeFromSuperview];
        [stackViewsByUUID removeObjectForKey:stackUUID];
    }

    [[MMAllStacksManager sharedInstance] deleteStack:stackUUID];

    if ([currentStackView.uuid isEqualToString:stackUUID]) {
        if (idx >= [[[MMAllStacksManager sharedInstance] stackIDs] count]) {
            idx -= 1;
        }

        if (idx == -1) {
            [self addStack];
        } else {
            [self switchToStack:[[[MMAllStacksManager sharedInstance] stackIDs] objectAtIndex:idx]];
        }
    }
    [listOfStacksView reloadStackButtons];
}

#pragma mark - MMPagesSidebarContainerViewDelegate

- (MMTutorialStackView*)stackForUUID:(NSString*)stackUUID {
    MMTutorialStackView* aStackView = stackViewsByUUID[stackUUID];

    if (!stackUUID) {
        stackUUID = [[MMAllStacksManager sharedInstance] createStack];
    }

    if (!aStackView) {
        aStackView = [[MMTutorialStackView alloc] initWithFrame:self.view.bounds andUUID:stackUUID];
        aStackView.stackDelegate = self;
        aStackView.deleteSidebar = deleteSidebar;
        [stackContainerView addSubview:aStackView];
        aStackView.center = self.view.center;

        stackViewsByUUID[stackUUID] = aStackView;

        if (!currentStackView) {
            currentStackView = aStackView;
        }

        [aStackView loadStacksFromDiskIntoPageView:[[NSUserDefaults standardUserDefaults] boolForKey:kIsShowingListView]];
    }

    return aStackView;
}

#pragma mark - MMMemoryManagerDelegate

- (int)fullByteSize {
    int fullByteSize = [[[stackViewsByUUID allValues] jotReduce:^id(MMTutorialStackView* obj, NSUInteger index, id accum) {
        return @([accum intValue] + obj.fullByteSize);
    }] intValue];

    return fullByteSize + importImageSidebar.fullByteSize + bezelScrapContainer.fullByteSize;
}

- (NSInteger)numberOfPages {
    return [[[stackViewsByUUID allValues] jotReduce:^id(MMTutorialStackView* obj, NSUInteger index, id accum) {
        return @([accum integerValue] + [obj.visibleStackHolder.subviews count] + [obj.hiddenStackHolder.subviews count]);
    }] integerValue];
}


#pragma mark - MMPageCacheManagerDelegate

- (BOOL)isPageInVisibleStack:(MMPaperView*)page {
    return [currentStackView isPageInVisibleStack:page];
}

- (MMPaperView*)getPageBelow:(MMPaperView*)page {
    return [currentStackView getPageBelow:page];
}

- (NSArray*)findPagesInVisibleRowsOfListView {
    NSArray* arr = [currentStackView findPagesInVisibleRowsOfListView] ?: @[];

    if (pageInActiveSidebarAnimation) {
        arr = [arr arrayByAddingObject:pageInActiveSidebarAnimation];
    }
    arr = [arr arrayByAddingObjectsFromArray:[self.bezelPagesContainer viewsInSidebar]];

    return arr;
}

- (NSArray*)pagesInCurrentBezelGesture {
    return [currentStackView pagesInCurrentBezelGesture];
}

- (BOOL)isShowingPageView {
    return [currentStackView isShowingPageView];
}

- (NSInteger)countAllPages {
    return [currentStackView countAllPages];
}

#pragma mark - MMInboxManagerDelegate

- (void)didProcessIncomingImage:(MMImageInboxItem*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [currentStackView didProcessIncomingImage:scrapBacking fromURL:url fromApp:sourceApplication];
}

- (void)didProcessIncomingPDF:(MMPDFInboxItem*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [currentStackView didProcessIncomingPDF:pdfDoc fromURL:url fromApp:sourceApplication];
}

- (void)failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [currentStackView failedToProcessIncomingURL:url fromApp:sourceApplication];
}


#pragma mark - MMCloudKitManagerDelegate

- (void)cloudKitDidChangeState:(MMCloudKitBaseState*)currentState {
    [sharePageSidebar cloudKitDidChangeState:currentState];
}

- (void)didFetchMessage:(SPRMessage*)message {
    [cloudKitExportView didFetchMessage:message];
}

- (void)didResetBadgeCountTo:(NSUInteger)badgeNumber {
    [cloudKitExportView didResetBadgeCountTo:badgeNumber];
}

#pragma mark - MMGestureTouchOwnershipDelegate

- (void)ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture {
    [currentStackView ownershipOfTouches:touches isGesture:gesture];
}

- (BOOL)isAllowedToPan {
    return [currentStackView isAllowedToPan];
}

- (BOOL)isAllowedToBezel {
    return [currentStackView isAllowedToBezel];
}

#pragma mark - MMRotationManagerDelegate


- (void)willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient {
    [currentStackView willRotateInterfaceFrom:fromOrient to:toOrient];
}

- (void)didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient {
    [currentStackView didRotateInterfaceFrom:fromOrient to:toOrient];
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)toOrient {
    [NSThread performBlockOnMainThread:^{
        @autoreleasepool {
            [sharePageSidebar updateInterfaceTo:toOrient];
            [importImageSidebar updateInterfaceTo:toOrient];
            [currentStackView didRotateToIdealOrientation:toOrient];
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self.bezelScrapContainer didRotateToIdealOrientation:toOrient];
                [self.bezelPagesContainer didRotateToIdealOrientation:toOrient];
            } completion:nil];
        }
    }];
}

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading {
    [currentStackView didUpdateAccelerometerWithReading:currentRawReading];
}

- (void)didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel {
    [currentStackView didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
}

#pragma mark - MMImageSidebarContainerViewDelegate

- (void)sidebarCloseButtonWasTapped:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelScrapContainer ||
        sidebar == importImageSidebar ||
        sidebar == sharePageSidebar) {
        [currentStackView sidebarCloseButtonWasTapped:sidebar];
    }
}

- (void)sidebarWillShow:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelScrapContainer ||
        sidebar == importImageSidebar ||
        sidebar == sharePageSidebar) {
        [currentStackView sidebarWillShow:sidebar];
    }
}

- (void)sidebarWillHide:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelScrapContainer ||
        sidebar == importImageSidebar ||
        sidebar == sharePageSidebar) {
        [currentStackView sidebarWillHide:sidebar];
    }
}

- (UIView*)viewForBlur {
    return [currentStackView viewForBlur];
}

#pragma mark - MMImageSidebarContainerViewDelegate

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView andRequestsImportAsPage:(BOOL)asPage {
    [currentStackView pictureTakeWithCamera:img fromView:cameraView andRequestsImportAsPage:asPage];
}

- (void)assetWasTapped:(MMDisplayAsset*)photo fromView:(MMBufferedImageView*)bufferedImage withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription andRequestsImportAsPage:(BOOL)asPage {
    [currentStackView assetWasTapped:photo fromView:bufferedImage withRotation:rotation fromContainer:containerDescription andRequestsImportAsPage:asPage];
}

#pragma mark - MMShareSidebarDelegate

- (void)exportToImage:(void (^)(NSURL*))completionBlock {
    [currentStackView exportToImage:completionBlock];
}

- (void)exportToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    [currentStackView exportToPDF:completionBlock];
}

- (NSDictionary*)cloudKitSenderInfo {
    return [currentStackView cloudKitSenderInfo];
}

- (void)didShare:(MMAbstractShareItem*)shareItem {
    [sharePageSidebar hide:YES onComplete:nil];
    [currentStackView didShare:shareItem];
}

- (void)mayShare:(MMAbstractShareItem*)shareItem {
    [currentStackView mayShare:shareItem];
}

- (void)wontShare:(MMAbstractShareItem*)shareItem {
    [currentStackView wontShare:shareItem];
}

- (void)didShare:(MMAbstractShareItem*)shareItem toUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)button {
    [cloudKitExportView didShareTopPageToUser:userId fromButton:button];
    [sharePageSidebar hide:YES onComplete:nil];

    [currentStackView didShare:shareItem toUser:userId fromButton:button];
}

#pragma mark - Release Notes

- (void)showReleaseNotesIfNeeded {
    if ([self isShowingAnyModal]) {
        // tutorial is already showing, just return
        return;
    }

    NSString* version = [UIApplication bundleShortVersionString];

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLastOpenedVersion: version}];

    //#ifdef DEBUG
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastOpenedVersion];
    //#endif

    if (version && ![[[NSUserDefaults standardUserDefaults] stringForKey:kLastOpenedVersion] isEqualToString:version]) {
        NSURL* releaseNotesFile = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"ReleaseNotes-%@", version] withExtension:@"md"];
        NSString* releaseNotes = [NSString stringWithContentsOfURL:releaseNotesFile encoding:NSUTF8StringEncoding error:nil];

        if (releaseNotes) {
            NSString* htmlReleaseNotes = [MMMarkdown HTMLStringWithMarkdown:releaseNotes error:nil];

            if (htmlReleaseNotes) {
                //#ifndef DEBUG
                [[NSUserDefaults standardUserDefaults] setObject:version forKey:kLastOpenedVersion];
                //#endif

                backdrop = [[UIView alloc] initWithFrame:self.view.bounds];
                backdrop.backgroundColor = [UIColor colorWithWhite:.5 alpha:1];
                backdrop.alpha = 0;
                [self.view addSubview:backdrop];

                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];

                releaseNotesViewController = [[MMReleaseNotesViewController alloc] initWithReleaseNotes:htmlReleaseNotes andCompletionBlock:^{
                    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
                        releaseNotesViewController = nil;
                    }];
                    [UIView animateWithDuration:.3 animations:^{
                        backdrop.alpha = 0;
                    }];
                }];

                [presentationWindow.rootViewController presentViewController:releaseNotesViewController animated:YES completion:nil];

                [UIView animateWithDuration:.3 animations:^{
                    backdrop.alpha = 1;
                }];
            }
        }
    }
}

#pragma mark - Tutorial Notifications

- (void)tutorialShouldOpen:(NSNotification*)note {
    if ([self isShowingAnyModal]) {
        // tutorial is already showing, just return
        return;
    }

    NSArray* tutorials = [note.userInfo objectForKey:@"tutorialList"];
    backdrop = [[UIView alloc] initWithFrame:self.view.bounds];
    backdrop.backgroundColor = [UIColor colorWithWhite:.5 alpha:1];
    backdrop.alpha = 0;
    [self.view addSubview:backdrop];

    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];

    tutorialViewController = [[MMTutorialViewController alloc] initWithTutorials:tutorials andCompletionBlock:^{
        [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
            tutorialViewController = nil;
        }];
        [UIView animateWithDuration:.3 animations:^{
            backdrop.alpha = 0;
        }];
    }];

    [presentationWindow.rootViewController presentViewController:tutorialViewController animated:YES completion:nil];

    [UIView animateWithDuration:.3 animations:^{
        backdrop.alpha = 1;
    }];
}

- (void)tutorialShouldClose:(NSNotification*)note {
    if (![self isShowingTutorial]) {
        // tutorial is already hidden, just return
        return;
    }

    [tutorialViewController closeTutorials];
}

#pragma mark - MMScrapSidebarContainerViewDelegate

- (void)willAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        [currentStackView willAddView:view toCountableSidebar:sidebar];
    }
}

- (void)didAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        [currentStackView didAddView:view toCountableSidebar:sidebar];
    } else {
        [self.bezelPagesContainer savePageContainerToDisk];
        [currentStackView saveStacksToDisk];
    }
}

- (void)willRemoveView:(UIView<MMUUIDView>*)view fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        [currentStackView willRemoveView:view fromCountableSidebar:sidebar];
    } else {
        pageInActiveSidebarAnimation = (MMPaperView*)view;
    }
}

- (void)didRemoveView:(UIView<MMUUIDView>*)view atIndex:(NSUInteger)index hadProperties:(BOOL)hadProperties fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        [currentStackView didRemoveView:view atIndex:index hadProperties:hadProperties fromCountableSidebar:sidebar];
    } else {
        pageInActiveSidebarAnimation = nil;
        [self.bezelPagesContainer savePageContainerToDisk];
        [currentStackView saveStacksToDisk];
    }
}

- (CGPoint)positionOnScreenToScaleViewTo:(UIView<MMUUIDView>*)view fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        return [currentStackView positionOnScreenToScaleViewTo:view fromCountableSidebar:sidebar];
    }

    return [currentStackView addPageBackToListViewAndAnimateOtherPages:(MMPaperView*)view];
}

- (CGFloat)scaleOnScreenToScaleViewTo:(UIView<MMUUIDView>*)view givenOriginalScale:(CGFloat)originalScale fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar {
    if (sidebar == bezelScrapContainer) {
        return [currentStackView scaleOnScreenToScaleViewTo:view givenOriginalScale:originalScale fromCountableSidebar:sidebar];
    }

    return 1.0;
}

- (MMScrappedPaperView*)pageForUUID:(NSString*)uuid {
    return [currentStackView pageForUUID:uuid];
}

@end
