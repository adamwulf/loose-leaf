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

@interface MMLooseLeafViewController ()<MMPaperStackViewDelegate>

@end

@implementation MMLooseLeafViewController{
    MMMemoryManager* memoryManager;
    MMDeletePageSidebarController* deleteSidebar;
    MMCloudKitImportExportView* cloudKitExportView;

    UIScrollView* listOfStacksView;
}

- (id)init{
    if(self = [super init]){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pageCacheManagerDidLoadPage)
                                                     name:kPageCacheManagerHasLoadedAnyPage
                                                   object:[MMPageCacheManager sharedInstance]];

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
        MMTextButton* aStackButton = [[MMTextButton alloc] initWithFrame:CGRectMake(100, 40, 60, 60) andFont:[UIFont systemFontOfSize:20] andLetter:@"A" andXOffset:0 andYOffset:0];
        aStackButton.tag = 1;
        [aStackButton addTarget:self action:@selector(switchToStack:) forControlEvents:UIControlEventTouchUpInside];
        [listOfStacksView addSubview:aStackButton];
        MMTextButton* bStackButton = [[MMTextButton alloc] initWithFrame:CGRectMake(200, 40, 60, 60) andFont:[UIFont systemFontOfSize:20] andLetter:@"B" andXOffset:0 andYOffset:0];
        [bStackButton addTarget:self action:@selector(switchToStack:) forControlEvents:UIControlEventTouchUpInside];
        [listOfStacksView addSubview:bStackButton];

        [self.view addSubview:listOfStacksView];

        memoryManager = [[MMMemoryManager alloc] initWithDelegate:self];

        // load the A stack first
        [self switchToStack:aStackButton];



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

#pragma mark - Multiple Stacks

-(void) switchToStack:(id)sender{

    if([sender tag]){
        // stack A view

        if(!aStackView){
            aStackView = [[MMTutorialStackView alloc] initWithFrame:self.view.bounds];
            aStackView.stackDelegate = self;
            aStackView.deleteSidebar = deleteSidebar;
            [self.view insertSubview:aStackView aboveSubview:deleteSidebar.deleteSidebarBackground];
            aStackView.center = self.view.center;

            [aStackView loadStacksFromDisk];
        }

        currentStackView = aStackView;
    }else{
        // b list
        if(!bStackView){
            bStackView = [[MMTutorialStackView alloc] initWithFrame:self.view.bounds];
            bStackView.stackDelegate = self;
            bStackView.deleteSidebar = deleteSidebar;
            [self.view insertSubview:bStackView aboveSubview:deleteSidebar.deleteSidebarBackground];
            bStackView.center = self.view.center;

            [aStackView loadStacksFromDisk];
        }

        currentStackView = bStackView;
    }

    currentStackView.cloudKitExportView = cloudKitExportView;
    cloudKitExportView.stackView = currentStackView;
    [[MMTouchVelocityGestureRecognizer sharedInstance] setStackView:currentStackView];

}

#pragma mark - MMMemoryManagerDelegate

-(int) fullByteSize{
    return aStackView.fullByteSize + bStackView.fullByteSize;
}

-(NSInteger) numberOfPages{
    return [aStackView.visibleStackHolder.subviews count] + [aStackView.hiddenStackHolder.subviews count] +
    [bStackView.visibleStackHolder.subviews count] + [bStackView.hiddenStackHolder.subviews count];
}

@end
