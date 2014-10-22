//
//  MMCloudKitTutorialImportCoodinator.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitTutorialImportCoordinator.h"
#import "NSString+UUID.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMCloudKitImportExportView.h"
#import "SPRMessage+Initials.h"
#import <ZipArchive/ZipArchive.h>
#import "MMCloudKitManager.h"
#import "Mixpanel.h"
#import "NSThread+BlockAdditions.h"
#import "MMReachabilityManager.h"
#import "MMCloudAvatarButton.h"

@implementation MMCloudKitTutorialImportCoordinator{
    MMAvatarButton* avatarButton;
    NSString* zipFileLocation;
    MMCloudKitImportExportView* importExportView;
    BOOL isReady;
    SPRMessage* message;
    
    // nil if the scrap unzip failed, or if
    // the coordinator hasn't begun
    NSString* uuidOfIncomingPage;
    NSString* targetPageLocation;
    NSInteger numberOfScrapsOnIncomingPage; // used for mixpanel only
    NSInteger numberOfVisibleScrapsOnIncomingPage; // used for mixpanel only
    NSInteger numberOfImportedScraps; // used for mixpanel only
    
    BOOL isWaitingOnNetwork;
}

+(BOOL) shouldShowTutorialImport{
    return ![[NSUserDefaults standardUserDefaults] objectForKey:kMPHasSeenCKTutorial];
}

@synthesize avatarButton;
@synthesize isReady;
@synthesize importExportView;

-(id) initWithImport:(SPRMessage*)importMessage forImportExportView:(MMCloudKitImportExportView*)_exportView{
    if(self = [super init]){
        avatarButton = [[MMCloudAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:@"CK"];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        importExportView = _exportView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

-(void) setImportExportView:(MMCloudKitImportExportView *)_importExportView{
    if(importExportView){
        @throw [NSException exceptionWithName:@"DuplicateSetExportViewForImportCoordinator" reason:@"Cannot set export view for coordinator that already has one" userInfo:nil];
    }
    importExportView = _importExportView;
}

-(void) reachabilityDidChange{
    // noop
}

-(void) begin{
    debug_NSLog(@"beginning tutorial import: list: %@  page: %@", [[NSUserDefaults standardUserDefaults] objectForKey:kMPHasZoomedToList],
                [[NSUserDefaults standardUserDefaults] objectForKey:kMPHasZoomedToPage]);
    if([[NSUserDefaults standardUserDefaults] objectForKey:kMPHasZoomedToList] &&
       [[NSUserDefaults standardUserDefaults] objectForKey:kMPHasZoomedToPage]){
        // they've got to list view + page view
        [[NSThread mainThread] performBlock:^{
            isReady = YES;
            NSLog(@"beginning already ready message %@", message.messageRecordID);
            [importExportView importCoordinatorIsReady:self];
        } afterDelay:1];
    }else{
        [self performSelector:@selector(begin) withObject:nil afterDelay:1];
    }
}

-(NSString*) uuidOfIncomingPage{
    return kMPCloudKitTutorialUUID;
}

#pragma mark - Touch Event

-(void) avatarButtonTapped:(MMAvatarButton*)button{
    // track that we've seen the tutorial to mixpanel
    [[[Mixpanel sharedInstance] people] set:@{kMPHasSeenCKTutorial : @(YES)}];
    // also track that we've seen the tutorial locally so that it doesn't re-show next time
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kMPHasSeenCKTutorial];
    [importExportView importWasTapped:self];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:@(isReady) forKey:@"isReady"];
}


- (id)initWithCoder:(NSCoder *)decoder{
    if(self = [super init]){
        isReady = [[decoder decodeObjectForKey:@"isReady"] boolValue];
        avatarButton = [[MMCloudAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:@"CK"];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


-(BOOL) matchesMessage:(SPRMessage*)otherMessage{
    return NO;
}

@end
