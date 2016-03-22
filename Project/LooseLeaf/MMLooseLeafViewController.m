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
#import "MMStacksManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMShareSidebarContainerView.h"
#import "NSArray+Map.h"

@interface MMLooseLeafViewController ()<MMPaperStackViewDelegate, MMPageCacheManagerDelegate, MMInboxManagerDelegate, MMCloudKitManagerDelegate, MMGestureTouchOwnershipDelegate, MMRotationManagerDelegate, MMImageSidebarContainerViewDelegate, MMShareItemDelegate>

@end

@implementation MMLooseLeafViewController{
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;
    MMCloudKitImportExportView* cloudKitExportView;

    UIScrollView* listOfStacksView;

    // image picker sidebar
    MMImageSidebarContainerView* importImageSidebar;

    // share sidebar
    MMShareSidebarContainerView* sharePageSidebar;

    NSMutableDictionary* stackViewsByUUID;
}

- (id)init{
    if(self = [super init]){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pageCacheManagerDidLoadPage)
                                                     name:kPageCacheManagerHasLoadedAnyPage
                                                   object:[MMPageCacheManager sharedInstance]];

        stackViewsByUUID = [NSMutableDictionary dictionary];

        [MMPageCacheManager sharedInstance].delegate = self;
        [MMInboxManager sharedInstance].delegate = self;
        [MMCloudKitManager sharedManager].delegate = self;
        [[MMRotationManager sharedInstance] setDelegate:self];


        // Do any additional setup after loading the view, typically from a nib.
        srand ((uint) time(NULL) );
        [[MMShadowManager sharedInstance] beginGeneratingShadows];
    
        self.view.opaque = YES;

        deleteSidebar = [[MMDeletePageSidebarController alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:deleteSidebar.deleteSidebarBackground];


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
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[[Mixpanel sharedInstance] people] set:kMPPreferredLanguage
                                             to:language];
        [[[Mixpanel sharedInstance] people] setOnce:@{kMPDidBackgroundDuringTutorial : @(NO),
                                                      kMPNewsletterStatus : @"Unknown",
                                                      kMPHasFinishedTutorial : @(NO),
                                                      kMPDurationWatchingTutorial: @(0),
                                                      kMPFirstLaunchDate : [NSDate date],
                                                      kMPHasAddedPage : @(NO),
                                                      kMPHasZoomedToList : @(NO),
                                                      kMPHasReorderedPage : @(NO),
                                                      kMPHasBookTurnedPage : @(NO),
                                                      kMPHasShakeToReorder : @(NO),
                                                      kMPHasBezelledScrap : @(NO),
                                                      kMPNumberOfPenUses : @(0),
                                                      kMPNumberOfEraserUses : @(0),
                                                      kMPNumberOfScissorUses : @(0),
                                                      kMPNumberOfRulerUses : @(0),
                                                      kMPNumberOfImports : @(0),
                                                      kMPNumberOfPhotoImports : @(0),
                                                      kMPNumberOfCloudKitImports : @(0),
                                                      kMPNumberOfPhotosTaken : @(0),
                                                      kMPNumberOfExports : @(0),
                                                      kMPNumberOfCloudKitExports : @(0),
                                                      kMPDurationAppOpen : @(0.0),
                                                      kMPNumberOfCrashes : @(0),
                                                      kMPDistanceDrawn : @(0.0),
                                                      kMPDistanceErased : @(0.0),
                                                      kMPNumberOfClippingExceptions : @(0.0),
                                                      kMPShareStatusCloudKit : kMPShareStatusUnknown,
                                                      kMPShareStatusFacebook : kMPShareStatusUnknown,
                                                      kMPShareStatusTwitter : kMPShareStatusUnknown,
                                                      kMPShareStatusEmail : kMPShareStatusUnknown,
                                                      kMPShareStatusSMS : kMPShareStatusUnknown,
                                                      kMPShareStatusTencentWeibo : kMPShareStatusUnknown,
                                                      kMPShareStatusSinaWeibo : kMPShareStatusUnknown,
                                                      }];
        [[Mixpanel sharedInstance] flush];

        UIImage* blackBlur = [UIImage imageNamed:@"blackblur.png"];
        self.view.layer.contents = (__bridge id)blackBlur.CGImage;



        // navigation between stacks

        listOfStacksView = [[MMStackControllerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 220)];
        listOfStacksView.alpha = 0;
        listOfStacksView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.92];


        for (int i=0; i<[[[MMStacksManager sharedInstance] stackIDs] count]; i++) {
            MMTextButton* switchToStackButton = [[MMTextButton alloc] initWithFrame:CGRectMake(100 * (i+1), 40, 60, 60) andFont:[UIFont systemFontOfSize:20] andLetter:[NSString stringWithFormat:@"%d", i] andXOffset:0 andYOffset:0];
            switchToStackButton.tag = i;
            [switchToStackButton addTarget:self action:@selector(switchToStack:) forControlEvents:UIControlEventTouchUpInside];
            [listOfStacksView addSubview:switchToStackButton];
        }

        [self.view addSubview:listOfStacksView];

        memoryManager = [[MMMemoryManager alloc] initWithDelegate:self];

        // Load the stack
        [self switchToStack:[listOfStacksView.subviews firstObject]];


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


        // Gesture Recognizers
        [self.view addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];

        [[MMDrawingTouchGestureRecognizer sharedInstance] setTouchDelegate:self];
        [self.view addGestureRecognizer:[MMDrawingTouchGestureRecognizer sharedInstance]];



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

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) pageCacheManagerDidLoadPage{
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPageCacheManagerHasLoadedAnyPage object:nil];
}

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication{
    // ask the inbox manager to
    [[MMInboxManager sharedInstance] processInboxItem:url fromApp:(NSString*)sourceApplication];
}

-(void) printKeys:(NSDictionary*)dict atlevel:(NSInteger)level{
    NSString* space = @"";
    for(int i=0;i<level;i++){
        space = [space stringByAppendingString:@" "];
    }
    for(NSString* key in [dict allKeys]){
        
        id obj = [dict objectForKey:key];
        if([obj isKindOfClass:[NSDictionary class]]){
            [self printKeys:obj atlevel:level+1];
        }else{
            if([obj isKindOfClass:[NSArray class]]){
                DebugLog(@"%@ %@ - %@ [%lu]", space, key, [obj class], (unsigned long)[obj count]);
            }else{
                DebugLog(@"%@ %@ - %@", space, key, [obj class]);
            }
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL) shouldAutorotate{
    return NO;
}


#pragma mark - application state

-(void) willResignActive{
    DebugLog(@"telling stack to cancel all gestures");
    NSLog(@"willResignActive");
    [currentStackView willResignActive];
    [currentStackView cancelAllGestures];
    [[currentStackView.visibleStackHolder peekSubview] cancelAllGestures];
}

-(void) didEnterBackground{
    NSLog(@"didEnterBackground");
    [currentStackView didEnterBackground];
}

-(void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:flag completion:completion];
//    DebugLog(@"dismissing view controller");
}

-(void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
//    DebugLog(@"presenting view controller");
}

#pragma mark - MMPaperStackViewDelegate

-(void) animatingToListView{
    listOfStacksView.alpha = 1;
}

-(void) animatingToPageView{
    listOfStacksView.alpha = 0;
}

-(MMImageSidebarContainerView*) importImageSidebar{
    return importImageSidebar;
}

-(MMShareSidebarContainerView*) sharePageSidebar{
    return sharePageSidebar;
}

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk{
    [cloudKitExportView didExportPage:page toZipLocation:fileLocationOnDisk];
}

-(void) didFailToExportPage:(MMPaperView*)page{
    [cloudKitExportView didFailToExportPage:page];
}

-(void) isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk{
    [cloudKitExportView isExportingPage:page withPercentage:percentComplete toZipLocation:fileLocationOnDisk];
}

#pragma mark - Multiple Stacks

-(void) switchToStack:(UIButton*)sender{
    if(sender.tag < [[[MMStacksManager sharedInstance] stackIDs] count]){
        NSString* stackUUID = [[[MMStacksManager sharedInstance] stackIDs] objectAtIndex:sender.tag];
        MMTutorialStackView* aStackView = stackViewsByUUID[stackUUID];

        if(!aStackView){
            aStackView = [[MMTutorialStackView alloc] initWithFrame:self.view.bounds andUUID:stackUUID];
            aStackView.stackDelegate = self;
            aStackView.deleteSidebar = deleteSidebar;
            [self.view insertSubview:aStackView aboveSubview:deleteSidebar.deleteSidebarBackground];
            aStackView.center = self.view.center;

            NSLog(@"Loading A stack: %@", stackUUID);

            [aStackView loadStacksFromDisk];

            if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowingListView"]){
                // open into list view if that was their last visible screen
                [aStackView immediatelyTransitionToListView];
                [aStackView setButtonsVisible:NO animated:NO];
            }

            stackViewsByUUID[stackUUID] = aStackView;
        }

        [stackViewsByUUID enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MMTutorialStackView*  _Nonnull obj, BOOL * _Nonnull stop) {
            obj.hidden = ![key isEqualToString:stackUUID];
        }];

        currentStackView = aStackView;

        [[MMPageCacheManager sharedInstance] updateVisiblePageImageCache];
        
        cloudKitExportView.stackView = currentStackView;
        [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:currentStackView];
    }
}

#pragma mark - MMMemoryManagerDelegate

-(int) fullByteSize{
    int fullByteSize = [[[stackViewsByUUID allValues] jotReduce:^id(MMTutorialStackView* obj, NSUInteger index, id accum) {
        return @([accum intValue] + obj.fullByteSize);
    }] intValue];

    return fullByteSize + importImageSidebar.fullByteSize;
}

-(NSInteger) numberOfPages{
    return [[[stackViewsByUUID allValues] jotReduce:^id(MMTutorialStackView* obj, NSUInteger index, id accum) {
        return @([accum integerValue] + [obj.visibleStackHolder.subviews count] + [obj.hiddenStackHolder.subviews count]);
    }] integerValue];
}


#pragma mark - MMPageCacheManagerDelegate

-(BOOL) isPageInVisibleStack:(MMPaperView*)page{
    return [currentStackView isPageInVisibleStack:page];
}

-(MMPaperView*) getPageBelow:(MMPaperView*)page{
    return [currentStackView getPageBelow:page];
}

-(NSArray*) findPagesInVisibleRowsOfListView{
    return [currentStackView findPagesInVisibleRowsOfListView];
}

-(NSArray*) pagesInCurrentBezelGesture{
    return [currentStackView pagesInCurrentBezelGesture];
}

-(BOOL) isShowingPageView{
    return [currentStackView isShowingPageView];
}

-(NSInteger) countAllPages{
    return [currentStackView countAllPages];
}

#pragma mark - MMInboxManagerDelegate

-(void) didProcessIncomingImage:(MMImageInboxItem*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    [currentStackView didProcessIncomingImage:scrapBacking fromURL:url fromApp:sourceApplication];
}

-(void) didProcessIncomingPDF:(MMPDFInboxItem*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    [currentStackView didProcessIncomingPDF:pdfDoc fromURL:url fromApp:sourceApplication];
}

-(void) failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    [currentStackView failedToProcessIncomingURL:url fromApp:sourceApplication];
}


#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState*)currentState{
    [sharePageSidebar cloudKitDidChangeState:currentState];
}

-(void) didFetchMessage:(SPRMessage*)message{
    [cloudKitExportView didFetchMessage:message];
}

-(void) didResetBadgeCountTo:(NSUInteger)badgeNumber{
    [cloudKitExportView didResetBadgeCountTo:badgeNumber];
}

#pragma mark - MMGestureTouchOwnershipDelegate

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [currentStackView ownershipOfTouches:touches isGesture:gesture];
}

-(BOOL) isAllowedToPan{
    return [currentStackView isAllowedToPan];
}

-(BOOL) isAllowedToBezel{
    return [currentStackView isAllowedToBezel];
}

#pragma mark - MMRotationManagerDelegate


-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    [currentStackView willRotateInterfaceFrom:fromOrient to:toOrient];
}

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    [currentStackView didRotateInterfaceFrom:fromOrient to:toOrient];
}

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)toOrient{
    @autoreleasepool {
        [sharePageSidebar updateInterfaceTo:toOrient];
        [importImageSidebar updateInterfaceTo:toOrient];
    }
    [currentStackView didRotateToIdealOrientation:toOrient];
}

-(void) didUpdateAccelerometerWithReading:(MMVector*)currentRawReading{
    [currentStackView didUpdateAccelerometerWithReading:currentRawReading];
}

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    [currentStackView didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
}

#pragma mark - MMImageSidebarContainerViewDelegate

-(void) sidebarCloseButtonWasTapped{
    [currentStackView sidebarCloseButtonWasTapped];
}

-(void) sidebarWillShow{
    [currentStackView sidebarWillShow];
}

-(void) sidebarWillHide{
    [currentStackView sidebarWillHide];
}

-(UIView*) viewForBlur{
    return [currentStackView viewForBlur];
}

-(UIImage*) imageForBlur{
    return [currentStackView imageForBlur];
}

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView{
    [currentStackView pictureTakeWithCamera:img fromView:cameraView];
}

-(void) photoWasTapped:(MMDisplayAsset *)photo fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription{
    [currentStackView photoWasTapped:photo fromView:bufferedImage withRotation:rotation fromContainer:containerDescription];
}

#pragma mark - MMShareItemDelegate

-(UIImage*) imageToShare{
    return [currentStackView imageToShare];
}

-(NSDictionary*) cloudKitSenderInfo{
    return [currentStackView cloudKitSenderInfo];
}

-(void) didShare:(NSObject<MMShareItem>*)shareItem{
    [sharePageSidebar hide:YES onComplete:nil];
    [currentStackView didShare:shareItem];
}

-(void) mayShare:(NSObject<MMShareItem>*)shareItem{
    [currentStackView mayShare:shareItem];
}

-(void) wontShare:(NSObject<MMShareItem>*)shareItem{
    [currentStackView wontShare:shareItem];
}

-(void) didShare:(NSObject<MMShareItem> *)shareItem toUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)button{
    [cloudKitExportView didShareTopPageToUser:userId fromButton:button];
    [sharePageSidebar hide:YES onComplete:nil];

    [currentStackView didShare:shareItem toUser:userId fromButton:button];
}


@end
