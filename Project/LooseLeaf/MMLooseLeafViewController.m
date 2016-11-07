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
#import "MMCollapsableStackView.h"
#import "MMCloudKitImportExportView.h"
#import "MMCollapsableStackViewDelegate.h"
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
#import "MMLooseLeafView.h"
#import "MMDebugStackView.h"


@interface MMLooseLeafViewController () <MMCollapsableStackViewDelegate, MMPageCacheManagerDelegate, MMInboxManagerDelegate, MMCloudKitManagerDelegate, MMGestureTouchOwnershipDelegate, MMRotationManagerDelegate, MMImageSidebarContainerViewDelegate, MMShareSidebarDelegate, MMScrapSidebarContainerViewDelegate, MMPagesSidebarContainerViewDelegate, MMListAddPageButtonDelegate>

@end


@implementation MMLooseLeafViewController {
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;
    MMCloudKitImportExportView* cloudKitExportView;

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

    MMPaperView* pageInActiveSidebarAnimation;

    UIScrollView* allStacksScrollView;

    MMListAddPageButton* addNewStackButton;

    BOOL isShowingCollapsedView;
}

@synthesize bezelPagesContainer;

- (id)init {
    if (self = [super init]) {
        NSString* viewModeForLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentViewMode];
        NSString* currentStackForLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentStack];

        mightShowReleaseNotes = YES;
        isShowingCollapsedView = YES;

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

        allStacksScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [allStacksScrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:allStacksScrollView];

        // init the add page button in top left of scrollview
        addNewStackButton = [[MMListAddPageButton alloc] initWithFrame:CGRectMake([MMListPaperStackView bufferWidth], [MMListPaperStackView bufferWidth], [MMListPaperStackView columnWidth], [MMListPaperStackView rowHeight])];
        addNewStackButton.delegate = self;
        [allStacksScrollView addSubview:addNewStackButton];

        // export icons will show here, below the sidebars but over the stacks
        cloudKitExportView = [[MMCloudKitImportExportView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:cloudKitExportView];
        // an extra view to help with animations
        MMUntouchableView* exportAnimationHelperView = [[MMUntouchableView alloc] initWithFrame:self.view.bounds];
        cloudKitExportView.animationHelperView = exportAnimationHelperView;
        [self.view addSubview:exportAnimationHelperView];

        [self.view addSubview:deleteSidebar.deleteSidebarForeground];


        // book keeping

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
                                                       kMPNumberOfPages: @(0),
                                                       kMPPushEnabled: @(NO)
        }];
        [[Mixpanel sharedInstance] flush];

        memoryManager = [[MMMemoryManager alloc] initWithDelegate:self];

        // Load the stack

        [self initializeAllStackViewsExcept:nil viewMode:viewModeForLaunch];

        // Image import sidebar
        importImageSidebar = [[MMImageSidebarContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMEditablePaperStackView insertImageButtonFrame] animateFromLeft:YES];
        importImageSidebar.delegate = self;
        [importImageSidebar hide:NO onComplete:nil];
        [self.view addSubview:importImageSidebar];

        // Share sidebar
        sharePageSidebar = [[MMShareSidebarContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMEditablePaperStackView shareButtonFrame] animateFromLeft:YES];
        sharePageSidebar.delegate = self;
        [sharePageSidebar hide:NO onComplete:nil];
        sharePageSidebar.shareDelegate = self;
        [self.view addSubview:sharePageSidebar];

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
        [self.view insertSubview:bezelPagesContainer belowSubview:allStacksScrollView];

        [bezelPagesContainer loadFromDisk];

        // Gesture Recognizers
        [self.view addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];
        [self.view addGestureRecognizer:[MMPalmGestureRecognizer sharedInstance]];
        [MMPalmGestureRecognizer sharedInstance].panDelegate = self;

        [[MMDrawingTouchGestureRecognizer sharedInstance] setTouchDelegate:self];
        [self.view addGestureRecognizer:[MMDrawingTouchGestureRecognizer sharedInstance]];

        // refresh button visibility after adding all our sidebars

        [currentStackView setButtonsVisible:[currentStackView buttonsVisible] animated:NO];
        [currentStackView immediatelyRelayoutIfInListMode];

        // setup the stack and page sidebar to be appropriately visible and collapsed/list/page
        if (![viewModeForLaunch isEqualToString:kViewModeCollapsed] && [[[MMAllStacksManager sharedInstance] stackIDs] count] && currentStackForLaunch) {
            [self didAskToSwitchToStack:currentStackForLaunch animated:NO viewMode:viewModeForLaunch];
        } else {
            [currentStackView setButtonsVisible:NO animated:NO];
            bezelPagesContainer.alpha = 0;
        }


        if (![[MMTutorialManager sharedInstance] hasFinishedTutorial]) {
            [[MMTutorialManager sharedInstance] startWatchingTutorials:[[MMTutorialManager sharedInstance] appIntroTutorialSteps]];
        }

        // Debug

        //        MMMemoryProfileView* memoryProfileView = [[MMMemoryProfileView alloc] initWithFrame:self.view.bounds];
        //        memoryProfileView.memoryManager = memoryManager;
        //        memoryProfileView.hidden = YES;
        //
        //        [stackView setMemoryView:memoryProfileView];
        //        [self.view addSubview:memoryProfileView];
        //        [self.view addSubview:[MMDebugStackView sharedView]];
    }
    return self;
}

- (void)loadView {
    MMLooseLeafView* looseLeafView = [[MMLooseLeafView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
    looseLeafView.looseLeafController = self;
    self.view = looseLeafView;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

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

- (MMScrapsInBezelContainerView*)bezelScrapContainer {
    return bezelScrapContainer;
}

- (MMPagesInBezelContainerView*)bezelPagesContainer {
    return bezelPagesContainer;
}

- (void)animatingToPageView {
    // noop
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

#pragma mark - MMCollapsableStackViewDelegate

- (void)didAskToSwitchToStack:(NSString*)stackUUID animated:(BOOL)animated viewMode:(NSString*)viewMode {
    MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

    if (!aStackView) {
        // don't allow switching to a stack that doesn't exist!
        return;
    }

    isShowingCollapsedView = NO;

    CGRect originalFrame = [aStackView convertRect:[aStackView bounds] toView:self.view];
    CGFloat originalMaxY = CGRectGetMaxY(originalFrame);

    // set the height immediately so that the animation of the pages expanding
    // isn't clipped
    originalFrame.size.height = CGRectGetHeight(self.view.bounds);
    aStackView.frame = originalFrame;
    [self.view insertSubview:aStackView aboveSubview:allStacksScrollView];
    if ([viewMode isEqualToString:kViewModeList]) {
        [aStackView organizePagesIntoListAnimated:animated];
    } else {
        [aStackView organizePagesIntoListAnimated:NO];
        [aStackView immediatelyTransitionToPageViewAnimated:animated];
    }

    [[MMPageCacheManager sharedInstance] willChangeTopPageTo:[[aStackView visibleStackHolder] peekSubview]];

    void (^animationStep)() = ^{
        NSInteger targetStackIndex = [[[MMAllStacksManager sharedInstance] stackIDs] indexOfObject:stackUUID];
        for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
            NSString* stackUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
            MMCollapsableStackView* stackView = [self stackForUUID:stackUUID];

            if (stackView == aStackView) {
                aStackView.frame = self.view.bounds;
            } else if (stackIndex < targetStackIndex) {
                CGFloat animationAmount = CGRectGetMinY(originalFrame) - allStacksScrollView.contentOffset.y;
                CGRect currFrame = stackView.frame;
                currFrame.origin.y -= animationAmount;
                stackView.frame = currFrame;
                stackView.alpha = 0;
            } else {
                CGFloat animationAmount = allStacksScrollView.contentOffset.y + CGRectGetHeight(self.view.bounds) - originalMaxY;
                CGRect currFrame = stackView.frame;
                currFrame.origin.y += animationAmount;
                stackView.frame = currFrame;
                stackView.alpha = 0;
            }
        }
        addNewStackButton.alpha = 0;
        bezelPagesContainer.alpha = 1;
    };

    void (^completionStep)(BOOL) = ^(BOOL completed) {
        MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];
        currentStackView = aStackView;

        [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];

        cloudKitExportView.stackView = currentStackView;
        [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:currentStackView];
        [[MMPageCacheManager sharedInstance] didChangeToTopPage:[[aStackView visibleStackHolder] peekSubview]];

        [[NSUserDefaults standardUserDefaults] setObject:stackUUID forKey:kCurrentStack];
    };

    if (animated) {
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:animationStep
                         completion:completionStep];
    } else {
        animationStep();
        completionStep(YES);
    }

    addNewStackButton.alpha = 0;
    allStacksScrollView.scrollEnabled = NO;
}

- (void)didAskToCollapseStack:(NSString*)stackUUID animated:(BOOL)animated {
    isShowingCollapsedView = YES;

    if (!allStacksScrollView.scrollEnabled) {
        allStacksScrollView.scrollEnabled = YES;
        MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

        [aStackView organizePagesIntoSingleRowAnimated:animated];

        void (^animationBlock)() = ^{
            [self initializeAllStackViewsExcept:stackUUID viewMode:kViewModeCollapsed];
            addNewStackButton.alpha = 1;
            bezelPagesContainer.alpha = 0;
        };

        void (^completedBlock)(BOOL) = ^(BOOL finished) {
            MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];
            CGRect fr = aStackView.frame;
            fr.size.height = [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
            aStackView.frame = fr;

            currentStackView = nil;
            addNewStackButton.alpha = 1;

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentStack];
        };

        if (animated) {
            [UIView animateWithDuration:.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:animationBlock
                             completion:completedBlock];
        } else {
            animationBlock();
            completedBlock(YES);
        }
    }
}

- (void)isPossiblyDeletingStack:(NSString*)stackUUID withPendingProbability:(CGFloat)probability {
    if ([self isShowingCollapsedView]) {
        allStacksScrollView.scrollEnabled = NO;
        [deleteSidebar showSidebarWithPercent:probability withTargetView:stackViewsByUUID[stackUUID]];
    }
}

- (void)isAskingToDeleteStack:(NSString*)stackUUID {
    if ([self isShowingCollapsedView]) {
        allStacksScrollView.scrollEnabled = YES;
        MMCollapsableStackView* stackView = stackViewsByUUID[stackUUID];
        [[MMAllStacksManager sharedInstance] deleteStack:stackUUID];

        [UIView animateWithDuration:.3 animations:^{
            [self initializeAllStackViewsExcept:stackUUID viewMode:kViewModeCollapsed];
            stackView.alpha = 0;
        } completion:^(BOOL finished) {
            [stackView removeFromSuperview];
            [stackViewsByUUID removeObjectForKey:stackUUID];
        }];
    }
}

- (void)isNotGoingToDeleteStack:(NSString*)stackUUID {
    if ([self isShowingCollapsedView]) {
        allStacksScrollView.scrollEnabled = YES;
        [deleteSidebar showSidebarWithPercent:0 withTargetView:stackViewsByUUID[stackUUID]];
    }
}

#pragma mark - MMStackControllerViewDelegate

- (MMCollapsableStackView*)stackForUUID:(NSString*)stackUUID {
    NSAssert(stackUUID, @"must have a stack uuid to fetch a stack");

    MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

    if (!aStackView) {
        aStackView = [[MMCollapsableStackView alloc] initWithFrame:self.view.bounds andUUID:stackUUID];
        aStackView.stackDelegate = self;
        aStackView.deleteSidebar = deleteSidebar;
        aStackView.center = self.view.center;

        [aStackView loadStacksFromDiskIntoListView];

        stackViewsByUUID[stackUUID] = aStackView;
    }
    return aStackView;
}

- (void)initializeAllStackViewsExcept:(NSString*)stackUUIDToSkipHeight viewMode:(NSString*)viewMode {
    CGFloat stackRowHeight = [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
    for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
        NSString* stackUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        if (![stackUUIDToSkipHeight isEqualToString:aStackView.uuid]) {
            if ([viewMode isEqualToString:kViewModeCollapsed]) {
                [aStackView organizePagesIntoSingleRowAnimated:NO];
            } else if ([viewMode isEqualToString:kViewModeList]) {
                [aStackView immediatelyTransitionToListView];
            } else {
                [aStackView immediatelyTransitionToPageViewAnimated:NO];
            }
        }
        CGRect fr = aStackView.bounds;
        if (![stackUUIDToSkipHeight isEqualToString:aStackView.uuid]) {
            fr = CGRectWithHeight(aStackView.bounds, stackRowHeight);
        }
        fr.origin.y = stackIndex * stackRowHeight;
        aStackView.frame = fr;
        [allStacksScrollView addSubview:aStackView];
        aStackView.alpha = 1;
        aStackView.scrollEnabled = NO;
    }

    [self realignAddStackButton];

    allStacksScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMaxY(addNewStackButton.frame) + [MMListPaperStackView bufferWidth]);
}

- (void)realignAddStackButton {
    CGFloat stackRowHeight = [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
    CGRect fr = addNewStackButton.frame;
    fr.origin.y = [[[MMAllStacksManager sharedInstance] stackIDs] count] * stackRowHeight + [MMListPaperStackView bufferWidth];
    addNewStackButton.frame = fr;
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
    NSArray* arr = @[];
    if ([self isShowingCollapsedView]) {
        for (MMCollapsableStackView* aStackView in [stackViewsByUUID allValues]) {
            arr = [arr arrayByAddingObjectsFromArray:[aStackView findPagesInVisibleRowsOfListView]];
        }
    } else {
        arr = [currentStackView findPagesInVisibleRowsOfListView] ?: @[];

        if (pageInActiveSidebarAnimation) {
            arr = [arr arrayByAddingObject:pageInActiveSidebarAnimation];
        }
        arr = [arr arrayByAddingObjectsFromArray:[self.bezelPagesContainer viewsInSidebar]];
    }

    return arr;
}

- (NSArray*)pagesInCurrentBezelGesture {
    return [currentStackView pagesInCurrentBezelGesture];
}

- (BOOL)isShowingPageView {
    return [currentStackView isShowingPageView] && !isShowingCollapsedView;
}

- (BOOL)isShowingListView {
    return [currentStackView isShowingListView] && !isShowingCollapsedView;
}

- (BOOL)isShowingCollapsedView {
    return isShowingCollapsedView;
}

- (NSInteger)countAllPages {
    return [currentStackView countAllPages];
}

#pragma mark - MMInboxManagerDelegate

- (void)didProcessIncomingImage:(MMImageInboxItem*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    if (currentStackView) {
        [currentStackView didProcessIncomingImage:scrapBacking fromURL:url fromApp:sourceApplication];
    } else {
        NSString* stackUUID = [[MMAllStacksManager sharedInstance] createStack:NO];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        [aStackView ensureAtLeast:1 pagesInStack:aStackView.visibleStackHolder];

        [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

        [self didAskToSwitchToStack:[aStackView uuid] animated:NO viewMode:kViewModePage];

        [aStackView didProcessIncomingImage:scrapBacking fromURL:url fromApp:sourceApplication];
    }
}

- (void)didProcessIncomingPDF:(MMPDFInboxItem*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    if (currentStackView) {
        [currentStackView didProcessIncomingPDF:pdfDoc fromURL:url fromApp:sourceApplication];
    } else {
        NSString* stackUUID = [[MMAllStacksManager sharedInstance] createStack:NO];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        [aStackView ensureAtLeast:1 pagesInStack:aStackView.visibleStackHolder];

        [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

        [self didAskToSwitchToStack:[aStackView uuid] animated:NO viewMode:kViewModePage];

        [aStackView didProcessIncomingPDF:pdfDoc fromURL:url fromApp:sourceApplication];
    }
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

- (UIView*)blurViewForSidebar:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelPagesContainer) {
        return self.view;
    }
    return [currentStackView blurViewForSidebar:sidebar];
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
    NSString* version = [UIApplication bundleShortVersionString];

    if ([self isShowingAnyModal]) {
        // tutorial is already showing, just return
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kLastOpenedVersion];
        return;
    }

    //#ifdef DEBUG
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastOpenedVersion];
    //#endif

    if (version && ![[[NSUserDefaults standardUserDefaults] stringForKey:kLastOpenedVersion] isEqualToString:version]) {
        NSURL* releaseNotesFile = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"ReleaseNotes-%@", version] withExtension:@"md"];
        NSString* releaseNotes = [NSString stringWithContentsOfURL:releaseNotesFile encoding:NSUTF8StringEncoding error:nil];

        if (releaseNotes) {
            NSString* htmlReleaseNotes = [MMMarkdown HTMLStringWithMarkdown:releaseNotes error:nil];

            if (htmlReleaseNotes) {
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

    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kLastOpenedVersion];
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

#pragma mark - MMListAddPageButtonDelegate

- (void)didTapAddButtonInListView {
    NSString* stackUUID = [[MMAllStacksManager sharedInstance] createStack:NO];
    MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
    [aStackView ensureAtLeast:3 pagesInStack:aStackView.visibleStackHolder];

    [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

    for (MMPaperView* page in [[aStackView visibleStackHolder] subviews]) {
        page.alpha = 0;
        page.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(.9, .9), -40, 0);
    }

    CGFloat delay = 0;
    for (MMPaperView* page in [[aStackView visibleStackHolder] subviews]) {
        [UIView animateWithDuration:.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            page.alpha = 1;
            page.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[page uuid] hash]));
        } completion:nil];
        delay += .1;
    }
}

@end
