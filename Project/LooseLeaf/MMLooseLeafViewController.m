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
#import "MMLargeTutorialSidebarButton.h"
#import "MMFeedbackButton.h"
#import "NSArray+MapReduce.h"
#import "UIScreen+MMSizing.h"
#import "UIColor+MMAdditions.h"
#import "MMRotatingBackgroundViewDelegate.h"
#import "MMShareStackSidebarContainerView.h"
#import "MMStopWatch.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMBackgroundStyleContainerView.h"
#import "MMBackgroundStyleContainerViewDelegate.h"
#import "MMPDFAssetGroup.h"
#import "MMDisplayAsset.h"


@interface MMLooseLeafViewController () <MMCollapsableStackViewDelegate, MMPageCacheManagerDelegate, MMInboxManagerDelegate, MMGestureTouchOwnershipDelegate, MMRotationManagerDelegate, MMImageSidebarContainerViewDelegate, MMShareSidebarDelegate, MMScrapSidebarContainerViewDelegate, MMPagesSidebarContainerViewDelegate, MMListAddPageButtonDelegate, UIScrollViewDelegate, MMRotatingBackgroundViewDelegate, MMShareStackSidebarDelegate, MMBackgroundStyleContainerViewDelegate>

@end


@implementation MMLooseLeafViewController {
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;

    MMRotatingBackgroundView* rotatingBackgroundView;

    // image picker sidebar
    MMImageSidebarContainerView* importImageSidebar;

    // page background sidebar
    MMBackgroundStyleContainerView* backgroundStyleSidebar;

    // share sidebar
    MMShareSidebarContainerView* sharePageSidebar;

    // share stack sidebar
    MMShareStackSidebarContainerView* shareStackSidebar;

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
    MMLargeTutorialSidebarButton* listViewTutorialButton;
    MMFeedbackButton* listViewFeedbackButton;

    BOOL isShowingCollapsedView;

    BOOL willPossiblyShowCollapsedView;

    CADisplayLink* displayLink;
    UIPanGestureRecognizer* panGesture;
    UILongPressGestureRecognizer* longPressGesture;
    CGPoint originalCenterOfHeldStackInView;
    CGPoint heldStackViewOffset;
    CGPoint originalGestureLocationInView;
    CGPoint mostRecentLocationOfMoveGestureInView;
    MMCollapsableStackView* heldStackView;

    BOOL isViewVisible;
    BOOL hasShownListCollapseTutorial;

    NSString* isActivelyExportingStackUUID;
}

@synthesize bezelPagesContainer;

- (id)init {
    if (self = [super init]) {
        NSString* viewModeForLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentViewMode];
        NSString* currentStackForLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentStack];

        if (!currentStackForLaunch) {
            viewModeForLaunch = kViewModeCollapsed;
        }

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


        // Do any additional setup after loading the view, typically from a nib.
        srand((uint)time(NULL));
        [[MMShadowManager sharedInstance] beginGeneratingShadows];

        self.view.opaque = YES;

        rotatingBackgroundView = [[MMRotatingBackgroundView alloc] initWithFrame:self.view.bounds];
        rotatingBackgroundView.delegate = self;
        [self.view addSubview:rotatingBackgroundView];

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
        allStacksScrollView.delegate = self;
        [allStacksScrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:allStacksScrollView];

        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressWithGesture:)];
        [allStacksScrollView addGestureRecognizer:longPressGesture];

        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressWithGesture:)];
        panGesture.minimumNumberOfTouches = 2;
        panGesture.maximumNumberOfTouches = 2;
        panGesture.delaysTouchesBegan = NO;
        [allStacksScrollView addGestureRecognizer:panGesture];

        // init the add page / tutorial / feedback buttons in the scrollview
        addNewStackButton = [[MMListAddPageButton alloc] initWithFrame:CGRectMake([MMListPaperStackView bufferWidth], [MMListPaperStackView bufferWidth], [MMListPaperStackView columnWidth], [MMListPaperStackView rowHeight])];
        addNewStackButton.delegate = self;

        CGRect typicalBounds = CGRectMake(0, 0, 80, 80);
        listViewTutorialButton = [[MMLargeTutorialSidebarButton alloc] initWithFrame:typicalBounds andTutorialList:^NSArray* {
            return [[MMTutorialManager sharedInstance] stackViewTutorialSteps];
        }];
        listViewTutorialButton.center = [self locationForTutorialButtonInCollapsedView];
        [listViewTutorialButton addTarget:self action:@selector(tutorialButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        listViewFeedbackButton = [[MMFeedbackButton alloc] initWithFrame:typicalBounds];
        listViewFeedbackButton.center = [self locationForFeedbackButtonInCollapsedView];
        [listViewFeedbackButton addTarget:self action:@selector(feedbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [allStacksScrollView addSubview:addNewStackButton];
        [allStacksScrollView addSubview:listViewTutorialButton];
        [allStacksScrollView addSubview:listViewFeedbackButton];

        [self.view addSubview:deleteSidebar.deleteSidebarForeground];

        // book keeping

        NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[[Mixpanel sharedInstance] people] set:kMPPreferredLanguage
                                             to:language];
        [[[Mixpanel sharedInstance] people] set:kMPiPadModel
                                             to:[UIDevice modelName]];

        [[[Mixpanel sharedInstance] people] setOnce:@{ kMPDidBackgroundDuringTutorial: @(NO),
                                                       kMPNewsletterStatus: @"Unknown",
                                                       kMPHasFinishedTutorial: @(NO),
                                                       kMPDurationWatchingTutorial: @(0),
                                                       kMPFirstLaunchDate: [NSDate date],
                                                       kMPHasAddedPage: @(NO),
                                                       kMPHasDeletedPage: @(NO),
                                                       kMPHasAddedStack: @(NO),
                                                       kMPHasDeletedStack: @(NO),
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
                                                       kMPNumberOfPhotosTaken: @(0),
                                                       kMPNumberOfExports: @(0),
                                                       kMPDurationAppOpen: @(0.0),
                                                       kMPNumberOfCrashes: @(0),
                                                       kMPDistanceDrawn: @(0.0),
                                                       kMPDistanceErased: @(0.0),
                                                       kMPNumberOfClippingExceptions: @(0.0),
                                                       kMPShareStatusFacebook: kMPShareStatusUnknown,
                                                       kMPShareStatusTwitter: kMPShareStatusUnknown,
                                                       kMPShareStatusEmail: kMPShareStatusUnknown,
                                                       kMPShareStatusSMS: kMPShareStatusUnknown,
                                                       kMPShareStatusTencentWeibo: kMPShareStatusUnknown,
                                                       kMPShareStatusSinaWeibo: kMPShareStatusUnknown,
                                                       kMPNumberOfPages: @(0),
                                                       kMPPushEnabled: @(NO),
                                                       kMPTwitterFollow: @(NO)
        }];
        [[Mixpanel sharedInstance] flush];

        memoryManager = [[MMMemoryManager alloc] initWithDelegate:self];

        // build a pages sidebar so that our stacks can
        // check with the sidebar if a page is orphaned or not
        CGRect frame = [self.view bounds];
        CGFloat rightBezelSide = frame.size.width - 100;
        CGFloat midPointY = (frame.size.height - 3 * 80) / 2;
        MMCountBubbleButton* countPagesButton = [[MMCountBubbleButton alloc] initWithFrame:CGRectMake(rightBezelSide, midPointY - 60, 80, 80)];
        bezelPagesContainer = [[MMPagesInBezelContainerView alloc] initWithFrame:frame andCountButton:countPagesButton];

        // Load the stacks. Build all of them, but only initialize non-current stack.
        // the current stack will be aligned after the sidebars
        [self initializeAllStackViewsExcept:nil viewMode:kViewModeList];

        // Image import sidebar
        importImageSidebar = [[MMImageSidebarContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMEditablePaperStackView insertImageButtonFrame] animateFromLeft:YES];
        importImageSidebar.delegate = self;
        [importImageSidebar hide:NO onComplete:nil];
        [self.view addSubview:importImageSidebar];

        // page background sidebar
        backgroundStyleSidebar = [[MMBackgroundStyleContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMEditablePaperStackView backgroundStyleButtonFrame] animateFromLeft:YES];
        backgroundStyleSidebar.delegate = self;
        backgroundStyleSidebar.bgDelegate = self;
        [backgroundStyleSidebar hide:NO onComplete:nil];
        [self.view addSubview:backgroundStyleSidebar];

        // Share sidebar
        sharePageSidebar = [[MMShareSidebarContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMEditablePaperStackView shareButtonFrame] animateFromLeft:YES];
        sharePageSidebar.delegate = self;
        [sharePageSidebar hide:NO onComplete:nil];
        sharePageSidebar.shareDelegate = self;
        [self.view addSubview:sharePageSidebar];

        // scrap sidebar
        frame = [self.view bounds];
        rightBezelSide = frame.size.width - 100;
        midPointY = (frame.size.height - 3 * 80) / 2;
        MMCountBubbleButton* countButton = [[MMCountBubbleButton alloc] initWithFrame:CGRectMake(rightBezelSide, midPointY - 60, 80, 80)];

        bezelScrapContainer = [[MMScrapsInBezelContainerView alloc] initWithFrame:frame andCountButton:countButton];
        bezelScrapContainer.delegate = self;
        bezelScrapContainer.bubbleDelegate = self;
        [self.view addSubview:bezelScrapContainer];

        [bezelScrapContainer loadFromDisk];

        // page sidebar
        bezelPagesContainer.delegate = self;
        bezelPagesContainer.bubbleDelegate = self;
        [self.view addSubview:bezelPagesContainer];

        [bezelPagesContainer loadFromDisk];

        // Share stack sidebar
        shareStackSidebar = [[MMShareStackSidebarContainerView alloc] initWithFrame:self.view.bounds forReferenceButtonFrame:[MMCollapsableStackView shareStackButtonFrame] animateFromLeft:NO];
        shareStackSidebar.delegate = self;
        [shareStackSidebar hide:NO onComplete:nil];
        shareStackSidebar.shareDelegate = self;
        [self.view addSubview:shareStackSidebar];

        // Gesture Recognizers
        [self.view addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];
        [self.view addGestureRecognizer:[MMPalmGestureRecognizer sharedInstance]];
        [MMPalmGestureRecognizer sharedInstance].panDelegate = self;

        [[MMDrawingTouchGestureRecognizer sharedInstance] setTouchDelegate:self];
        [self.view addGestureRecognizer:[MMDrawingTouchGestureRecognizer sharedInstance]];

        // refresh button visibility after adding all our sidebars

        MMCollapsableStackView* initialStackView = nil;

        if (currentStackForLaunch) {
            initialStackView = stackViewsByUUID[currentStackForLaunch];
        }

        // setup the stack and page sidebar to be appropriately visible and collapsed/list/page
        if (![viewModeForLaunch isEqualToString:kViewModeCollapsed] && [[[MMAllStacksManager sharedInstance] stackIDs] count] && currentStackForLaunch && initialStackView) {
            [self didAskToSwitchToStack:currentStackForLaunch animated:NO viewMode:viewModeForLaunch];
        } else {
            [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

            [currentStackView setButtonsVisible:NO animated:NO];
            bezelPagesContainer.alpha = 0;
            bezelScrapContainer.alpha = 0;
        }


        if (![[MMTutorialManager sharedInstance] hasFinishedTutorial]) {
            [[MMTutorialManager sharedInstance] startWatchingTutorials:[[MMTutorialManager sharedInstance] appIntroTutorialSteps]];
        }

        [NSThread performBlockInBackground:^{
            @autoreleasepool {
                displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScrollOffsetDuringDrag)];
                displayLink.paused = YES;
                [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            }
        }];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        [[MMRotationManager sharedInstance] setDelegate:self];

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    isViewVisible = YES;

    [self rotatingBackgroundViewDidUpdate:rotatingBackgroundView];

    [self checkToShowListCollapseTutorial];

    [self deleteOldTmpFiles];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    isViewVisible = NO;
}

- (void)checkToShowListCollapseTutorial {
    BOOL hasEverCollapsed = [[NSUserDefaults standardUserDefaults] boolForKey:kHasEverCollapsedToShowAllStacks];
    if ([self isShowingListView] && !hasShownListCollapseTutorial && ![self isShowingAnyModal] && !hasEverCollapsed) {
        hasShownListCollapseTutorial = YES;
        [currentStackView showCollapsedAnimation:nil];
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

- (MMBackgroundStyleContainerView*)backgroundStyleSidebar {
    return backgroundStyleSidebar;
}

- (MMShareSidebarContainerView*)sharePageSidebar {
    return sharePageSidebar;
}

- (MMShareStackSidebarContainerView*)shareStackSidebar {
    return shareStackSidebar;
}

- (BOOL)isShowingAnyModal {
    return [self isShowingTutorial] || [self isShowingReleaseNotes] || [self isShowingFeedbackForm];
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

- (void)didAskToChangeButtonOpacity:(BOOL)visible animated:(BOOL)animated forStack:(NSString*)stackUUID {
    if ([[currentStackView uuid] isEqualToString:stackUUID]) {
        if (animated) {
            if (self.bezelScrapContainer.alpha != visible ? 1 : 0) {
                [UIView animateWithDuration:.3 animations:^{
                    self.bezelScrapContainer.alpha = visible ? 1 : 0;
                    self.bezelPagesContainer.alpha = visible ? 0 : 1;
                }];
            } else {
                self.bezelScrapContainer.alpha = visible ? 1 : 0;
                self.bezelPagesContainer.alpha = visible ? 0 : 1;
            }
        } else {
            self.bezelScrapContainer.alpha = visible ? 1 : 0;
            self.bezelPagesContainer.alpha = visible ? 0 : 1;
        }
    }
}

- (void)didChangeToListView:(NSString*)stackUUID {
    if ([[currentStackView uuid] isEqualToString:stackUUID]) {
        [self.view insertSubview:bezelPagesContainer aboveSubview:bezelScrapContainer];
    }
}

- (void)willChangeToPageView:(NSString*)stackUUID {
    if ([[currentStackView uuid] isEqualToString:stackUUID]) {
        [self.view insertSubview:bezelPagesContainer belowSubview:allStacksScrollView];
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

#pragma mark - MMCollapsableStackViewDelegate

- (void)didAskToSwitchToStack:(NSString*)stackUUID animated:(BOOL)animated viewMode:(NSString*)viewMode {
    MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

    if (!aStackView) {
        // don't allow switching to a stack that doesn't exist!
        return;
    }

    NSArray<MMCollapsableStackView*>* importingStacks = [[allStacksScrollView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable obj, NSDictionary<NSString*, id>* _Nullable bindings) {
        if ([obj isKindOfClass:[MMCollapsableStackView class]]) {
            MMCollapsableStackView* anyStackView = (MMCollapsableStackView*)obj;
            return [anyStackView isCurrentlyHandlingImport];
        }
        return NO;
    }]];

    if ([importingStacks count]) {
        // don't all switching to a stack while an import is in progress
        [self safelyScrollToOffsetY:CGRectGetMinY([importingStacks[0] frame]) animated:YES];
        return;
    }


    // we need to change the current stack immediatley and not wait for the
    // animation to complete. This way, the notifications from the stack
    // as it is switched to will properly layout the page sidebar above/below
    // the stack.
    currentStackView = aStackView;
    isShowingCollapsedView = NO;

    longPressGesture.enabled = NO;
    panGesture.enabled = NO;

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
        [aStackView immediatelyTransitionToPageViewAnimated:animated];
    }

    if ([[aStackView visibleStackHolder] peekSubview]) {
        [[MMPageCacheManager sharedInstance] willChangeTopPageTo:[[aStackView visibleStackHolder] peekSubview]];
    }

    void (^animationStep)() = ^{
        NSInteger targetStackIndex = [[[MMAllStacksManager sharedInstance] stackIDs] indexOfObject:stackUUID];
        for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
            NSString* stackUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
            MMCollapsableStackView* stackView = [self stackForUUID:stackUUID];

            if (stackView == aStackView) {
                aStackView.frame = self.view.bounds;
            } else if (stackIndex < targetStackIndex) {
                CGFloat animationAmount = CGRectGetMinY(originalFrame);
                CGRect currFrame = stackView.frame;
                currFrame.origin.y -= animationAmount;
                stackView.frame = currFrame;
                stackView.alpha = 0;
            } else {
                CGFloat animationAmount = CGRectGetHeight(self.view.bounds) - originalMaxY;
                CGRect currFrame = stackView.frame;
                currFrame.origin.y += animationAmount;
                stackView.frame = currFrame;
                stackView.alpha = 0;
            }
        }

        CGFloat animationAmountForButtons = CGRectGetHeight(self.view.bounds) - originalMaxY;

        addNewStackButton.center = CGPointTranslate([self locationForAddStackButtonInCollapsedView], 0, animationAmountForButtons);
        listViewTutorialButton.center = CGPointTranslate([self locationForTutorialButtonInCollapsedView], 0, animationAmountForButtons);
        listViewFeedbackButton.center = CGPointTranslate([self locationForFeedbackButtonInCollapsedView], 0, animationAmountForButtons);
        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;

        addNewStackButton.alpha = 0;

        if ([viewMode isEqualToString:kViewModeList]) {
            bezelPagesContainer.alpha = 1;
        } else {
            bezelPagesContainer.alpha = 0;
        }

        [self updateStackNameColorsAnimated:YES];
    };

    void (^completionStep)(BOOL) = ^(BOOL completed) {
        [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];

        [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:currentStackView];
        [[MMPageCacheManager sharedInstance] didChangeToTopPage:[[aStackView visibleStackHolder] peekSubview]];

        [[NSUserDefaults standardUserDefaults] setObject:stackUUID forKey:kCurrentStack];

        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;
        addNewStackButton.alpha = 0;

        [self updateOtherStackVisibilityForCurrentStack:NO];
        [self checkToShowListCollapseTutorial];
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

    allStacksScrollView.scrollEnabled = NO;
}

- (CGFloat)idealYForYOffset:(CGFloat)targetYOffset {
    CGFloat fullHeight = [self contentHeightForAllStacks];
    CGFloat idealY = MIN(targetYOffset + [UIScreen screenHeight] * 3.0 / 5.0, fullHeight);
    idealY = MAX(0, idealY - [UIScreen screenHeight]);
    return idealY;
}

- (void)safelyScrollToOffsetY:(CGFloat)targetYOffset animated:(BOOL)animated {
    CGFloat idealY = [self idealYForYOffset:targetYOffset];
    [allStacksScrollView setContentOffset:CGPointMake(0, idealY) animated:animated];
}

- (void)didAskToCollapseStack:(NSString*)stackUUID animated:(BOOL)animated {
    if (animated) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasEverCollapsedToShowAllStacks];
    }

    isShowingCollapsedView = YES;

    longPressGesture.enabled = YES;
    panGesture.enabled = YES;

    CGFloat targetYOffset = [[[MMAllStacksManager sharedInstance] stackIDs] indexOfObject:stackUUID] * [self stackRowHeight];
    [self safelyScrollToOffsetY:targetYOffset animated:NO];

    if (!allStacksScrollView.scrollEnabled) {
        allStacksScrollView.scrollEnabled = YES;
        MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

        [self updateOtherStackVisibilityForCurrentStack:YES];
        [aStackView organizePagesIntoSingleRowAnimated:animated];

        CGRect fr = [aStackView convertRect:[aStackView bounds] toView:allStacksScrollView];
        [allStacksScrollView addSubview:aStackView];
        aStackView.frame = fr;

        void (^animationBlock)() = ^{
            CGRect frWithY = fr;
            [self initializeAllStackViewsExcept:stackUUID viewMode:kViewModeCollapsed];
            frWithY.origin.y = [self targetYForFrameForStackInCollapsedList:aStackView.uuid];
            aStackView.frame = frWithY;
            addNewStackButton.alpha = 1;
            listViewFeedbackButton.alpha = 1;
            listViewTutorialButton.alpha = 1;
            bezelPagesContainer.alpha = 0;

            [self updateStackNameColorsAnimated:YES];
        };

        void (^completedBlock)(BOOL) = ^(BOOL finished) {
            MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];
            CGRect fr = aStackView.frame;
            fr.size.height = [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
            aStackView.frame = fr;

            currentStackView = nil;
            addNewStackButton.alpha = 1;
            listViewFeedbackButton.alpha = 1;
            listViewTutorialButton.alpha = 1;

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

- (void)mightAskToCollapseStack:(NSString*)stackUUID {
    if (!willPossiblyShowCollapsedView) {
        willPossiblyShowCollapsedView = YES;
        [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
    }
}

- (void)didNotAskToCollapseStack:(NSString*)stackUUID {
    if (willPossiblyShowCollapsedView) {
        willPossiblyShowCollapsedView = NO;
        [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
    }
}

- (void)isPossiblyDeletingStack:(NSString*)stackUUID withPendingProbability:(CGFloat)probability {
    if ([self isShowingCollapsedView:stackUUID]) {
        allStacksScrollView.scrollEnabled = NO;
        [deleteSidebar showSidebarWithPercent:probability withTargetView:stackViewsByUUID[stackUUID]];

        // check if any other stack is showing a delete confirmation / buttons,
        // and reset their UI if so
        BOOL needsReset = NO;
        for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
            NSString* otherUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
            if (![otherUUID isEqualToString:stackUUID]) {
                MMCollapsableStackView* aStackView = [self stackForUUID:otherUUID];
                needsReset = needsReset || ![aStackView isPerfectlyAlignedIntoRow];
            }
        }

        if (needsReset) {
            // now we know that at least 1 stack needs to be reset into a row,
            // so animate that now
            [UIView animateWithDuration:.3 animations:^{
                for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
                    NSString* otherUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
                    if (![otherUUID isEqualToString:stackUUID]) {
                        MMCollapsableStackView* aStackView = [self stackForUUID:otherUUID];
                        [aStackView cancelPendingConfirmationsAndResetToRow];
                    }
                }
            }];
        }
    }
}

- (void)isAskingToDeleteStack:(NSString*)stackUUID {
    if ([self isShowingCollapsedView:stackUUID]) {
        allStacksScrollView.scrollEnabled = YES;
        MMCollapsableStackView* stackView = stackViewsByUUID[stackUUID];
        [[MMAllStacksManager sharedInstance] deleteStack:stackUUID];

        [UIView animateWithDuration:.3 animations:^{
            [self initializeAllStackViewsExcept:stackUUID viewMode:kViewModeCollapsed];
            stackView.alpha = 0;
        } completion:^(BOOL finished) {
            [stackView removeFromSuperview];
            [stackViewsByUUID removeObjectForKey:stackUUID];

            [[[Mixpanel sharedInstance] people] set:@{ kMPHasDeletedStack: @(YES) }];
        }];
    }
}

- (void)isNotGoingToDeleteStack:(NSString*)stackUUID {
    if ([self isShowingCollapsedView:stackUUID]) {
        allStacksScrollView.scrollEnabled = YES;
        [deleteSidebar showSidebarWithPercent:0 withTargetView:stackViewsByUUID[stackUUID]];
    }
}

- (BOOL)isAllowedToInteractWithStack:(NSString*)stackUUID {
    return heldStackView == nil && ![self stackIfNameInputFirstResponder];
}

- (void)isBeginningToEditName:(NSString*)stackUUID {
    if ([self isShowingCollapsedView:stackUUID]) {
        allStacksScrollView.scrollEnabled = NO;
    }
}

- (void)didFinishEditingName:(NSString*)stackUUID {
    if ([self isShowingCollapsedView:stackUUID]) {
        allStacksScrollView.scrollEnabled = YES;
    }
}

- (void)didAskToExportStack:(NSString*)stackUUID {
    isActivelyExportingStackUUID = stackUUID;
}


#pragma mark - MMStackControllerViewDelegate

- (CGFloat)stackRowHeight {
    return [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
}

- (MMCollapsableStackView*)stackForUUID:(NSString*)stackUUID {
    NSAssert(stackUUID, @"must have a stack uuid to fetch a stack");

    MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];

    if (!aStackView) {
        aStackView = [[MMCollapsableStackView alloc] initWithFrame:self.view.bounds andUUID:stackUUID];
        aStackView.stackDelegate = self;
        aStackView.deleteSidebar = deleteSidebar;
        aStackView.center = self.view.center;

        [aStackView loadStacksFromDiskIntoListViewIgnoringMeta:self.bezelPagesContainer.pagesMeta];

        stackViewsByUUID[stackUUID] = aStackView;
    }
    return aStackView;
}

- (CGFloat)targetYForFrameForStackAtIndex:(NSInteger)stackIndex {
    return stackIndex * [self stackRowHeight];
}

- (CGFloat)targetYForFrameForStackInCollapsedList:(NSString*)stackUUID {
    NSInteger stackIndex = [[[MMAllStacksManager sharedInstance] stackIDs] indexOfObject:stackUUID];
    return [self targetYForFrameForStackAtIndex:stackIndex];
}

- (NSInteger)targetIndexForYInCollapsedList:(CGFloat)targetY {
    CGFloat stackRowHeight = [self stackRowHeight];
    return targetY / stackRowHeight;
}

- (void)initializeAllStackViewsExcept:(NSString*)stackUUIDToSkipHeight viewMode:(NSString*)viewMode {
    CGFloat stackRowHeight = [self stackRowHeight];
    NSArray* allStackIds = [[MMAllStacksManager sharedInstance] stackIDs];
    for (NSInteger stackIndex = 0; stackIndex < [allStackIds count]; stackIndex++) {
        NSString* stackUUID = allStackIds[stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        if (![stackUUIDToSkipHeight isEqualToString:aStackView.uuid]) {
            if ([viewMode isEqualToString:kViewModeCollapsed] && ![[aStackView currentViewMode] isEqualToString:kViewModeCollapsed]) {
                [aStackView organizePagesIntoSingleRowAnimated:NO];
            } else if ([viewMode isEqualToString:kViewModeList] && ![[aStackView currentViewMode] isEqualToString:kViewModeList]) {
                [aStackView immediatelyTransitionToListView];
            } else if ([viewMode isEqualToString:kViewModePage] && ![[aStackView currentViewMode] isEqualToString:kViewModePage]) {
                [aStackView immediatelyTransitionToPageViewAnimated:NO];
            }
        }
        if (![stackUUIDToSkipHeight isEqualToString:aStackView.uuid]) {
            CGRect fr = CGRectWithHeight(aStackView.bounds, stackRowHeight);
            fr.origin.y = [self targetYForFrameForStackAtIndex:stackIndex];
            aStackView.frame = fr;
            if (![allStacksScrollView.subviews containsObject:aStackView]) {
                [allStacksScrollView addSubview:aStackView];
            }
        }
        aStackView.alpha = 1;
        aStackView.scrollEnabled = NO;
    }

    [self realignAddStackButton];

    // add 140 for the tutorial and feedback buttons
    allStacksScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMaxY(addNewStackButton.frame) + [MMListPaperStackView bufferWidth] + 140);
}

- (void)realignAddStackButton {
    addNewStackButton.center = [self locationForAddStackButtonInCollapsedView];
    listViewTutorialButton.center = [self locationForTutorialButtonInCollapsedView];
    listViewFeedbackButton.center = [self locationForFeedbackButtonInCollapsedView];
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
    NSArray* allStackIds = [[MMAllStacksManager sharedInstance] stackIDs];
    if ([self isShowingCollapsedView:[currentStackView uuid]] || willPossiblyShowCollapsedView) {
        CGFloat bottomY = MAX(0, allStacksScrollView.contentOffset.y);
        if (currentStackView) {
            NSInteger indexForCurrentStack = [allStackIds indexOfObject:[currentStackView uuid]];
            bottomY = [self targetYForFrameForStackAtIndex:indexForCurrentStack];
            bottomY = [self idealYForYOffset:bottomY];
        }

        for (NSInteger stackIndex = 0; stackIndex < [allStackIds count]; stackIndex++) {
            NSString* stackUUID = allStackIds[stackIndex];
            MMCollapsableStackView* aStackView = stackViewsByUUID[stackUUID];
            CGFloat y = [self targetYForFrameForStackAtIndex:stackIndex];
            CGFloat topY = bottomY + CGRectGetHeight([allStacksScrollView bounds]);
            topY = MIN(topY, allStacksScrollView.contentSize.height);
            bottomY = MAX(0, topY - CGRectGetHeight([allStacksScrollView bounds]));

            if (y < topY && y + [self stackRowHeight] > bottomY) {
                // only add stacks that will be visible in our scrolled area
                arr = [arr arrayByAddingObjectsFromArray:[aStackView findPagesInVisibleRowsOfListView]];
            }
        }

        if (willPossiblyShowCollapsedView) {
            // only don't load the page sidebar into cache
            // if we're already in collapsed view. still load
            // if we're not yet in collapsed view.
            arr = [arr arrayByAddingObjectsFromArray:[self.bezelPagesContainer viewsInSidebar]];
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

// return YES if the input stack is in collapsed mode
// NO otherwise.
- (BOOL)isShowingCollapsedView:(NSString*)stackUUID {
    return isShowingCollapsedView || (!currentStackView || ![[currentStackView uuid] isEqualToString:stackUUID]);
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
        [self didAskToCollapseStack:currentStackView.uuid animated:NO];
    }

    [longPressGesture setEnabled:NO];
    [panGesture setEnabled:NO];

    NSString* stackUUID = [[MMAllStacksManager sharedInstance] createStack:NO];
    MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];

    [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

    CGPoint offset = CGPointMake(0, allStacksScrollView.contentSize.height - CGRectGetHeight(allStacksScrollView.bounds));
    offset.y = MAX(offset.y, 0);
    [allStacksScrollView setContentOffset:offset animated:NO];

    [aStackView showUIToPrepareForImportingPDF:pdfDoc onComplete:^{
        // check to see if the user decrypted it if necessary
        if (![pdfDoc isEncrypted]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MMStopWatch* timer = [[MMStopWatch alloc] init];
                [timer start];
                [aStackView importAllPagesFromPDFInboxItem:pdfDoc fromSourceApplication:sourceApplication onComplete:^(BOOL success) {
                    // done importing
                    CGFloat duration = [timer stop];
                    NSString* result = success ? @"Success" : @"Cancelled";

                    if (success) {
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(pdfDoc.pdf.pageCount)];
                        [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedPage: @(YES) }];
                    }

                    NSMutableDictionary* properties = [@{ kMPEventImportPropFileExt: [url fileExtension] ?: @"png",
                                                          kMPEventImportPropFileType: [url universalTypeID] ?: [NSURL UTIForExtension:@"png"],
                                                          kMPEventImportPropResult: result,
                                                          kMPEventImportDuration: @(duration),
                                                          kMPNumberOfPages: @(pdfDoc.pdf.pageCount) } mutableCopy];
                    if (sourceApplication) {
                        properties[kMPEventImportPropSourceApplication] = sourceApplication;
                    }

                    [[Mixpanel sharedInstance] track:kMPEventImportStack properties:properties];

                    [longPressGesture setEnabled:YES];
                    [panGesture setEnabled:YES];
                }];
            });
        } else {
            [longPressGesture setEnabled:YES];
            [panGesture setEnabled:YES];
        }
    }];
}

- (void)failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication {
    [currentStackView failedToProcessIncomingURL:url fromApp:sourceApplication];
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
            [shareStackSidebar updateInterfaceTo:toOrient];

            for (NSString* stackUUIDs in [[MMAllStacksManager sharedInstance] stackIDs]) {
                MMCollapsableStackView* aStackView = [self stackForUUID:stackUUIDs];
                [aStackView didRotateToIdealOrientation:toOrient];
            }

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
        sidebar == sharePageSidebar ||
        sidebar == backgroundStyleSidebar) {
        [currentStackView sidebarCloseButtonWasTapped:sidebar];
    }
}

- (void)sidebarWillShow:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelScrapContainer ||
        sidebar == importImageSidebar ||
        sidebar == sharePageSidebar ||
        sidebar == backgroundStyleSidebar) {
        [currentStackView sidebarWillShow:sidebar];
    }
}

- (void)sidebarWillHide:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelScrapContainer ||
        sidebar == importImageSidebar ||
        sidebar == sharePageSidebar ||
        sidebar == backgroundStyleSidebar) {
        [currentStackView sidebarWillHide:sidebar];
    }
}

- (UIView*)blurViewForSidebar:(MMFullScreenSidebarContainingView*)sidebar {
    if (sidebar == bezelPagesContainer || sidebar == shareStackSidebar) {
        return self.view;
    }
    return [currentStackView blurViewForSidebar:sidebar];
}

#pragma mark - MMImageSidebarContainerViewDelegate

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView andRequestsImportAsPage:(BOOL)asPage {
    [currentStackView pictureTakeWithCamera:img fromView:cameraView andRequestsImportAsPage:asPage];
}

- (void)assetWasTapped:(MMDisplayAsset*)photo fromView:(UIView<MMDisplayAssetCoordinator>*)assetView withBackgroundColor:(UIColor*)color withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription andRequestsImportAsPage:(BOOL)asPage {
    [currentStackView assetWasTapped:photo fromView:assetView withBackgroundColor:color withRotation:rotation fromContainer:containerDescription andRequestsImportAsPage:asPage];
}

#pragma mark - MMShareSidebarDelegate

- (ExportRotation)idealExportRotation {
    return [currentStackView idealExportRotation];
}

- (void)setIdealExportRotation:(ExportRotation)idealExportRotation {
    return [currentStackView setIdealExportRotation:idealExportRotation];
}

- (void)exportVisiblePageToImage:(void (^)(NSURL*))completionBlock {
    [currentStackView exportVisiblePageToImage:completionBlock];
}

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    [currentStackView exportVisiblePageToPDF:completionBlock];
}

- (void)didShare:(MMAbstractShareItem*)shareItem {
    [sharePageSidebar hide:YES onComplete:nil];
    [shareStackSidebar hide:YES onComplete:nil];
    [currentStackView didShare:shareItem];
}

- (void)mayShare:(MMAbstractShareItem*)shareItem {
    [currentStackView mayShare:shareItem];
}

- (void)wontShare:(MMAbstractShareItem*)shareItem {
    [currentStackView wontShare:shareItem];
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
        NSURL* releaseNotesFile = [[NSBundle mainBundle] URLForResource:@"ReleaseNotes" withExtension:@"md"];
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
    __block MMScrappedPaperView* page = [currentStackView pageForUUID:uuid];

    if (!page) {
        [[stackViewsByUUID allValues] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
            // already checked currentStackView
            page = [obj pageForUUID:uuid];

            *stop = page != nil;
        }];
    }

    return page;
}

#pragma mark - MMListAddPageButtonDelegate

- (void)didTapAddButtonInListView {
    NSString* stackUUID = [[MMAllStacksManager sharedInstance] createStack:NO];
    MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];

    [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];

    [aStackView ensureAtLeastPagesInStack:3];

    [[[Mixpanel sharedInstance] people] set:@{ kMPHasAddedStack: @(YES) }];
}

#pragma mark - Tutorial and Feedback

- (CGFloat)contentHeightForAllStacks {
    CGFloat stackRowHeight = [MMListPaperStackView bufferWidth] * 2 + [MMListPaperStackView rowHeight];
    return stackRowHeight * ([[[MMAllStacksManager sharedInstance] stackIDs] count] + 1) + 140;
}

- (CGPoint)locationForAddStackButtonInCollapsedView {
    CGFloat stackRowHeight = [self stackRowHeight];
    CGRect fr = addNewStackButton.frame;
    fr.origin.y = [[[MMAllStacksManager sharedInstance] stackIDs] count] * stackRowHeight + [MMListPaperStackView bufferWidth];
    return CGRectGetMidPoint(fr);
}

- (CGPoint)locationForTutorialButtonInCollapsedView {
    CGFloat adjustment = (CGRectGetWidth([listViewTutorialButton bounds]) + kWidthOfSidebarButtonBuffer) / 2;
    return CGPointMake([UIScreen screenWidth] / 2 - adjustment, [self contentHeightForAllStacks] - 110);
}

- (CGPoint)locationForFeedbackButtonInCollapsedView {
    CGFloat adjustment = (CGRectGetWidth([listViewTutorialButton bounds]) + kWidthOfSidebarButtonBuffer) / 2;
    return CGPointMake([UIScreen screenWidth] / 2 + adjustment, [self contentHeightForAllStacks] - 110);
}

- (void)feedbackButtonPressed:(MMTutorialSidebarButton*)tutorialButton {
    [self stackViewDidPressFeedbackButton:nil];
}

- (void)tutorialButtonPressed:(MMTutorialSidebarButton*)tutorialButton {
    [[MMTutorialManager sharedInstance] startWatchingTutorials:tutorialButton.tutorialList];
}

#pragma mark - Long Press

- (void)didLongPressWithGesture:(UILongPressGestureRecognizer*)gesture {
    CGPoint pointInScrollView = [gesture locationInView:allStacksScrollView];
    mostRecentLocationOfMoveGestureInView = [gesture locationInView:self.view];

    if ([gesture state] == UIGestureRecognizerStateBegan) {
        if (![self isAllowedToInteractWithStack:nil]) {
            [gesture setEnabled:NO];
            [gesture setEnabled:YES];
            return;
        }

        [[allStacksScrollView subviews] enumerateObjectsUsingBlock:^(__kindof UIView* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
            if ([obj isKindOfClass:[MMCollapsableStackView class]]) {
                MMCollapsableStackView* aStackView = (MMCollapsableStackView*)obj;
                // only allow moving stack views
                if (CGRectContainsPoint([aStackView frame], pointInScrollView)) {
                    if ([aStackView isCurrentlyHandlingImport] || ![aStackView isPerfectlyAlignedIntoRow]) {
                        // only allow moving stacks that are perfectly aligned
                        // and not currently importing
                        [gesture setEnabled:NO];
                        [gesture setEnabled:YES];
                        return;
                    }

                    heldStackView = aStackView;
                    heldStackViewOffset = [heldStackView effectiveRowCenter];
                    originalGestureLocationInView = mostRecentLocationOfMoveGestureInView;

                    originalCenterOfHeldStackInView = [heldStackView convertPoint:CGRectGetMidPoint([heldStackView bounds]) toView:self.view];
                    [self.view addSubview:heldStackView];
                    heldStackView.center = originalCenterOfHeldStackInView;

                    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

                        CGFloat diff = CGRectGetWidth([heldStackView bounds]) / 2 - heldStackViewOffset.x;

                        [heldStackView squashPagesWhenInRowView:.2 withTranslate:80 + diff];
                        heldStackView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        heldStackView.stackNameField.transform = CGAffineTransformMakeScale(.909, .909);
                    } completion:nil];

                    displayLink.paused = NO;
                }
            }
        }];

        if (!heldStackView) {
            // don't continue the gesture if we're not holding a stack
            [gesture setEnabled:NO];
            [gesture setEnabled:YES];
        }
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        [self updateIndexOfHeldStackDuringGestureAndScroll];
    } else if ([gesture state] == UIGestureRecognizerStateEnded ||
               [gesture state] == UIGestureRecognizerStateCancelled ||
               [gesture state] == UIGestureRecognizerStateFailed) {
        displayLink.paused = YES;
        CGPoint p = [heldStackView convertPoint:CGRectGetMidPoint([heldStackView bounds]) toView:allStacksScrollView];
        [allStacksScrollView addSubview:heldStackView];
        heldStackView.center = p;

        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [heldStackView squashPagesWhenInRowView:0 withTranslate:0];
            heldStackView.stackNameField.transform = CGAffineTransformIdentity;
            heldStackView.transform = CGAffineTransformIdentity;
            heldStackView.userInteractionEnabled = YES;

            if (heldStackView) {
                // only reset if we were holding a stack.
                // we might've been cancelled before the gesture truly began
                [self initializeAllStackViewsExcept:nil viewMode:kViewModeCollapsed];
            }
        } completion:^(BOOL finished) {
            heldStackView = nil;
        }];
    }
}

- (void)updateIndexOfHeldStackDuringGestureAndScroll {
    if ([longPressGesture state] == UIGestureRecognizerStateChanged || [panGesture state] == UIGestureRecognizerStateChanged) {
        // moving
        CGPoint translation = CGPointMake(mostRecentLocationOfMoveGestureInView.x - originalGestureLocationInView.x, mostRecentLocationOfMoveGestureInView.y - originalGestureLocationInView.y);
        CGPoint translatedCenter = originalCenterOfHeldStackInView;
        translatedCenter.y += translation.y;
        heldStackView.center = translatedCenter;

        CGPoint locInScroll = [self.view convertPoint:translatedCenter toView:allStacksScrollView];
        NSInteger updatedStackIndex = [self targetIndexForYInCollapsedList:locInScroll.y];

        [[MMAllStacksManager sharedInstance] moveStack:heldStackView.uuid toIndex:updatedStackIndex];

        __block NSInteger stackIndex = 0;
        BOOL shouldAnimate = [allStacksScrollView.subviews reduceToBool:^BOOL(__kindof UIView* obj, NSUInteger index, BOOL accum) {
            if ([obj isKindOfClass:[MMCollapsableStackView class]]) {
                MMCollapsableStackView* aStackView = (MMCollapsableStackView*)obj;
                if (aStackView == heldStackView) {
                    return accum;
                }

                CGFloat targetY = [self targetYForFrameForStackAtIndex:stackIndex];
                stackIndex += 1;

                return roundf(aStackView.frame.origin.y) != roundf(targetY) || accum;
            } else {
                return accum;
            }
        }];

        if (shouldAnimate) {
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self initializeAllStackViewsExcept:heldStackView.uuid viewMode:kViewModeCollapsed];
            } completion:nil];
        }
    }
}

- (void)updateScrollOffsetDuringDrag {
    /**
     * this helper block accepts an offset that may or may not
     * be within the size bounds of the scroll view.
     * the offset may be negative, or may be far below
     * the end of the list of pages.
     *
     * the returned value is guarenteed to be the correct
     * offset that will keep the pages visible on screen
     * (including the add page button)
     */
    CGFloat (^validateOffset)(CGPoint) = ^(CGPoint possibleOffset) {
        CGPoint actualOffset = possibleOffset;
        CGFloat fullHeight = allStacksScrollView.contentSize.height;
        if (actualOffset.y > fullHeight - [UIScreen screenHeight]) {
            actualOffset.y = fullHeight - [UIScreen screenHeight];
        }
        if (actualOffset.y < 0) {
            actualOffset.y = 0;
        }
        return possibleOffset.y - actualOffset.y;
    };

    //
    // we're going to normalize the drag based on the
    // midpoint of the screen.
    CGFloat directionAndAmplitude = mostRecentLocationOfMoveGestureInView.y - [UIScreen screenHeight] / 2;
    // make the max speed faster
    directionAndAmplitude *= 1.5;

    // save the middle half of the screen so that
    // we never scroll
    //
    // anything above/below the middle half will begin
    // to scroll
    if (directionAndAmplitude > [UIScreen screenHeight] / 4) {
        directionAndAmplitude -= [UIScreen screenHeight] / 4;
    } else if (directionAndAmplitude < -[UIScreen screenHeight] / 4) {
        directionAndAmplitude += [UIScreen screenHeight] / 4;
    } else {
        directionAndAmplitude = 0;
    }

    if (directionAndAmplitude) {
        //
        // the directionAndAmplitude is the number of points
        // above/below the midpoint. so scale it down so that
        // the user drags roughly 256 / 20 = 12 pts per
        // display update
        CGFloat offsetDelta = directionAndAmplitude * displayLink.duration * 3;
        CGPoint newOffset = allStacksScrollView.contentOffset;
        newOffset.y += offsetDelta;
        CGFloat delta = validateOffset(newOffset);
        newOffset.y -= delta;
        allStacksScrollView.contentOffset = newOffset;
    }
}

- (void)updateOtherStackVisibilityForCurrentStack:(BOOL)allShouldBeVisible {
    NSArray* allStackIds = [[MMAllStacksManager sharedInstance] stackIDs];
    for (NSInteger stackIndex = 0; stackIndex < [allStackIds count]; stackIndex++) {
        NSString* stackUUID = allStackIds[stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];

        CGFloat topY = [self targetYForFrameForStackAtIndex:stackIndex];
        CGFloat bottomY = topY + [self stackRowHeight];

        if (allShouldBeVisible || currentStackView == aStackView || (bottomY >= [allStacksScrollView contentOffset].y && topY <= [allStacksScrollView contentOffset].y + CGRectGetHeight([allStacksScrollView bounds]))) {
            [aStackView setHidden:NO];
        } else {
            [aStackView setHidden:YES];
        }
    }
}

- (void)updateStackNameColorsAnimated:(BOOL)animated {
    NSArray* allStackIds = [[MMAllStacksManager sharedInstance] stackIDs];
    for (NSInteger stackIndex = 0; stackIndex < [allStackIds count]; stackIndex++) {
        NSString* stackUUID = allStackIds[stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];

        CGFloat topY = [self targetYForFrameForStackAtIndex:stackIndex];
        CGFloat bottomY = topY + [self stackRowHeight];

        if (currentStackView == aStackView || (bottomY >= [allStacksScrollView contentOffset].y && topY <= [allStacksScrollView contentOffset].y + CGRectGetHeight([allStacksScrollView bounds]))) {
            CGPoint p = [aStackView convertPoint:CGRectGetMidPoint([aStackView rectForColorConsideration]) toView:rotatingBackgroundView];
            UIColor* color1 = [rotatingBackgroundView colorFromPoint:p];
            UIColor* color2 = [rotatingBackgroundView colorFromPoint:CGPointTranslate(p, -CGRectGetWidth([aStackView rectForColorConsideration]) / 2, 0)];
            UIColor* color3 = [rotatingBackgroundView colorFromPoint:CGPointTranslate(p, CGRectGetWidth([aStackView rectForColorConsideration]) / 2, 0)];
            UIColor* original = [[color1 blendWithColor:color2 withPercent:.5] blendWithColor:color3 withPercent:.3];

            [aStackView setNameColor:original animated:animated];
        }
    }
}

#pragma mark - MMRotatingBackgroundViewDelegate

- (void)rotatingBackgroundViewDidUpdate:(MMRotatingBackgroundView*)backgroundView {
    [self updateOtherStackVisibilityForCurrentStack:YES];
    [self updateStackNameColorsAnimated:isViewVisible];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    [self updateStackNameColorsAnimated:NO];
    [self updateIndexOfHeldStackDuringGestureAndScroll];
    [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
}

- (void)enableAllSmoothBorders:(BOOL)enable {
    NSArray* allStackIds = [[MMAllStacksManager sharedInstance] stackIDs];
    for (NSInteger stackIndex = 0; stackIndex < [allStackIds count]; stackIndex++) {
        NSString* stackUUID = allStackIds[stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        NSArray* pages = [aStackView pagesToAlignForRowView];
        for (MMEditablePaperView* page in pages) {
            [page setSmoothBorder:enable];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self enableAllSmoothBorders:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self enableAllSmoothBorders:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
    [self enableAllSmoothBorders:YES];
}

#pragma mark - Keyboard

- (MMCollapsableStackView*)stackIfNameInputFirstResponder {
    for (NSInteger stackIndex = 0; stackIndex < [[[MMAllStacksManager sharedInstance] stackIDs] count]; stackIndex++) {
        NSString* stackUUID = [[MMAllStacksManager sharedInstance] stackIDs][stackIndex];
        MMCollapsableStackView* aStackView = [self stackForUUID:stackUUID];
        if ([aStackView.stackNameField isFirstResponder]) {
            return aStackView;
        }
    }
    return nil;
}

- (void)adjustKeyboardForStack:(MMCollapsableStackView*)stack givenKeyboardUserInfo:(NSDictionary*)userInfo {
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect stackFrame = [stack convertRect:[stack bounds] toView:nil];
        if (CGRectIntersectsRect(keyboardFrame, stackFrame)) {
            CGFloat insetForKeyboard = CGRectGetHeight(stackFrame) + CGRectGetHeight(keyboardFrame) - 40;

            allStacksScrollView.contentInset = UIEdgeInsetsMake(0, 0, insetForKeyboard, 0);
        } else {
            allStacksScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    } completion:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    MMCollapsableStackView* stackView = [self stackIfNameInputFirstResponder];

    if (stackView) {
        [self adjustKeyboardForStack:stackView givenKeyboardUserInfo:notification.userInfo];
    }
}

#pragma mark - MMShareStackSidebarDelegate

- (NSString*)nameOfCurrentStack {
    return [[currentStackView stackManager] name];
}

- (void)exportStackToPDF:(void (^)(NSURL* urlToPDF))completionBlock withProgress:(BOOL (^)(NSInteger pageSoFar, NSInteger totalPages))progressBlock {
    if (isActivelyExportingStackUUID) {
        MMCollapsableStackView* stack = [self stackForUUID:isActivelyExportingStackUUID];
        [stack exportStackToPDF:completionBlock withProgress:progressBlock];
        isActivelyExportingStackUUID = nil;
    } else {
        [currentStackView exportStackToPDF:completionBlock withProgress:progressBlock];
    }
}

#pragma mark - MMBackgroundStyleContainerViewDelegate

- (NSString*)currentBackgroundStyleType {
    return [currentStackView currentBackgroundStyleType];
}

- (void)setCurrentBackgroundStyleType:(NSString*)currentBackgroundStyle {
    [MMBackgroundedPaperView setDefaultBackgroundClass:currentBackgroundStyle];
    [currentStackView setCurrentBackgroundStyleType:currentBackgroundStyle];
}

#pragma mark - Tmp Files

- (void)deleteOldTmpFiles {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL* directoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator* directoryEnumerator =

            [fileManager enumeratorAtURL:directoryURL
                includingPropertiesForKeys:@[NSURLCreationDateKey]
                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                              errorHandler:nil];

        NSMutableArray<NSURL*>* filesToDelete = [NSMutableArray array];
        for (NSURL* fileURL in directoryEnumerator) {
            NSDate* createdDate = nil;
            [fileURL getResourceValue:&createdDate forKey:NSURLCreationDateKey error:nil];

            if ([createdDate earlierDate:[NSDate dateWithTimeIntervalSinceNow:-60 * 15]] == createdDate) {
                // if the file was created more than 15 minutes ago, then delete it
                [filesToDelete addObject:fileURL];
            }
        }

        for (NSURL* urlToDelete in filesToDelete) {
            [fileManager removeItemAtURL:urlToDelete error:nil];
        }
    });
}

@end
