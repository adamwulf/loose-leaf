//
//  MMCloudKitImportCoordinator.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitImportCoordinator.h"
#import "NSString+UUID.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMCloudKitImportExportView.h"
#import "SPRMessage+Initials.h"
#import <ZipArchive/ZipArchive.h>
#import "MMCloudKitManager.h"
#import "Mixpanel.h"
#import "NSThread+BlockAdditions.h"


// step 1: fetch message from CloudKit
// step 2: unzip file into Pages directory
// step 3: notify that we're ready
@implementation MMCloudKitImportCoordinator{
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

@synthesize avatarButton;
@synthesize isReady;
@synthesize importExportView;

-(id) initWithImport:(SPRMessage*)importMessage forImportExportView:(MMCloudKitImportExportView*)_exportView{
    if(self = [super init]){
        NSLog(@"creating new import for %@", importMessage.messageRecordID);
        message = importMessage;
        importExportView = _exportView;
        avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:message.initials];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        avatarButton.letter = @"RW";
        isReady = YES;
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
    NSLog(@"beginning already ready message %@", message.messageRecordID);
    dispatch_async(dispatch_get_main_queue(), ^{
        [importExportView importCoordinatorIsReady:self];
    });
    return;
}

-(NSString*) uuidOfIncomingPage{
    return kUUIDOfHerPage;
}

#pragma mark - Touch Event

-(void) avatarButtonTapped:(MMAvatarButton*)button{
    NSMutableDictionary* eventProperties = [@{kMPEventImportPropScrapCount : @(numberOfScrapsOnIncomingPage),
                                   kMPEventImportPropVisibleScrapCount : @(numberOfVisibleScrapsOnIncomingPage)} mutableCopy];
    if(message.attributes){
        if(message.attributes){
            for(NSString* key in [message.attributes allKeys]){
                [eventProperties setObject:[message.attributes objectForKey:key] forKey:[NSString stringWithFormat:@"ImportAttr: %@", key]];
            }
        }
    }
    
    // track addition of the page + its scraps in our count
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPages by:@(1)];
    if(numberOfImportedScraps){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScraps by:@(numberOfImportedScraps)];
    }
    
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfImports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCloudKitImports by:@(1)];
    [eventProperties setObject:@"CloudKit" forKey:kMPEventImportPropSource];
    [eventProperties setObject:@"Success" forKey:kMPEventImportPropResult];
    [[Mixpanel sharedInstance] track:kMPEventImportPage properties:eventProperties];
    
    [importExportView importWasTapped:self];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:message forKey:@"message"];
    
    if(zipFileLocation) [encoder encodeObject:zipFileLocation forKey:@"zipFileLocation"];
    if(uuidOfIncomingPage) [encoder encodeObject:uuidOfIncomingPage forKey:@"uuidOfIncomingPage"];
    if(targetPageLocation) [encoder encodeObject:targetPageLocation forKey:@"targetPageLocation"];
    [encoder encodeObject:@(numberOfScrapsOnIncomingPage) forKey:@"numberOfScrapsOnIncomingPage"];
    [encoder encodeObject:@(numberOfVisibleScrapsOnIncomingPage) forKey:@"numberOfVisibleScrapsOnIncomingPage"];
    [encoder encodeObject:@(numberOfImportedScraps) forKey:@"numberOfImportedScraps"];
    [encoder encodeObject:@(isReady) forKey:@"isReady"];
}


- (id)initWithCoder:(NSCoder *)decoder{
    if(self = [super init]){
        message = [decoder decodeObjectForKey:@"message"];
        
        zipFileLocation = [decoder decodeObjectForKey:@"zipFileLocation"];
        avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:message.initials];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        uuidOfIncomingPage = [decoder decodeObjectForKey:@"uuidOfIncomingPage"];
        targetPageLocation = [decoder decodeObjectForKey:@"targetPageLocation"];
        numberOfScrapsOnIncomingPage = [[decoder decodeObjectForKey:@"numberOfScrapsOnIncomingPage"] integerValue];
        numberOfVisibleScrapsOnIncomingPage = [[decoder decodeObjectForKey:@"numberOfVisibleScrapsOnIncomingPage"] integerValue];
        numberOfImportedScraps = [[decoder decodeObjectForKey:@"numberOfImportedScraps"] integerValue];
        isReady = YES;
    }
    return self;
}


-(BOOL) matchesMessage:(SPRMessage*)otherMessage{
    return !otherMessage.messageRecordID || [message.messageRecordID isEqual:otherMessage.messageRecordID];
}

@end
