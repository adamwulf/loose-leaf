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
#import "MMReachabilityManager.h"


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
        DebugLog(@"creating new import for %@", importMessage.messageRecordID);
        message = importMessage;
        importExportView = _exportView;
        avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:message.initials];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setImportExportView:(MMCloudKitImportExportView *)_importExportView{
    if(importExportView){
        @throw [NSException exceptionWithName:@"DuplicateSetExportViewForImportCoordinator" reason:@"Cannot set export view for coordinator that already has one" userInfo:nil];
    }
    importExportView = _importExportView;
}

-(void) reachabilityDidChange{
    if(isWaitingOnNetwork){
        if([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
            DebugLog(@"Import: network is back online, restarting download");
            // we're allowed to startup our download again
            isWaitingOnNetwork = NO;
            [self begin];
        }
    }
}

-(void) begin{
    if(self.isReady){
        DebugLog(@"beginning already ready message %@", message.messageRecordID);
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [importExportView importCoordinatorIsReady:self];
            }
        });
        return;
    }
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable){
        DebugLog(@"Import: network is offline, waiting for internet");
        isWaitingOnNetwork = YES;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            //
            // Step 1:
            // fetch the message details so that we have the sender
            // and message information, including the attached zip file
            DebugLog(@"fetching message details %@", message.messageRecordID);
            [message fetchDetailsWithCompletionHandler:^(NSError *error) {
                if(!error){
                    if(!zipFileLocation){
                        NSString* targetZipDirectory = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"IncomingPages"];
                        [NSFileManager ensureDirectoryExistsAtPath:targetZipDirectory];
                        NSString* movedZipFileLocation = [targetZipDirectory stringByAppendingPathComponent:[NSString createStringUUID]];
                        NSError* err;
                        [[NSFileManager defaultManager] copyItemAtPath:message.messageData.path toPath:movedZipFileLocation error:&err];
                        DebugLog(@"target path: %@", movedZipFileLocation);
                        DebugLog(@"target folder exists? %d", [[NSFileManager defaultManager] fileExistsAtPath:targetZipDirectory]);
                        if(err){
                            DebugLog(@"failed to copy zip: %@", err);
                        }else{
                            zipFileLocation = movedZipFileLocation;
                            DebugLog(@"fetched message details, have zip at: %@", zipFileLocation);
                        }
                        
                        // update our state with the new info
                        avatarButton.letter = message.initials;
                    }else{
                        DebugLog(@"already had cached details for %@", message.messageRecordID);
                    }
                    [importExportView importCoordinatorHasAssetsAndIsProcessing:self];
                    
                    //
                    // Step 2:
                    // now that we have the zip file, we need to unzip it into place.
                    // The contents will be processed into the IncomingPages directory.
                    // and once the page has been validated and assigned a new UUID,
                    // it will be moved into the Pages directory ready for user import.
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        @autoreleasepool {
                            ZipArchive* zip = [[ZipArchive alloc] init];
                            if([zip validateZipFileAt:zipFileLocation]){
                                // continue processing
                                
                                // we define our own UUID for the incoming page
                                NSString* tmpUUIDOfIncomingPage = [NSString createStringUUID];
                                // we'll put all the files into this directory for now
                                NSString* tempPathOfIncomingPage = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"IncomingPages"] stringByAppendingPathComponent:tmpUUIDOfIncomingPage];
                                
                                ZipArchive* zip = [[ZipArchive alloc] init];
                                if([zip unzipOpenFile:zipFileLocation]){
                                    // make sure target directory exists
                                    [[NSFileManager defaultManager] createDirectoryAtPath:tempPathOfIncomingPage withIntermediateDirectories:YES attributes:nil error:nil];
                                    // unzip files
                                    [zip unzipFileTo:tempPathOfIncomingPage overWrite:NO];
                                    
                                    NSString* pathToScrapsPlist = [[tempPathOfIncomingPage stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
                                    NSString* pathToScrapsInPage = [tempPathOfIncomingPage stringByAppendingPathComponent:@"Scraps"];
                                    
                                    NSDictionary* originalScrapPlist = [NSDictionary dictionaryWithContentsOfFile:pathToScrapsPlist];
                                    NSMutableDictionary* renamedScraps = [NSMutableDictionary dictionary];
                                    
                                    // track the number of scraps that were imported with this page
                                    numberOfImportedScraps = [[originalScrapPlist objectForKey:@"scrapsOnPageIDs"] count];
                                    
                                    // update the scrap properties to point to new UUIDs
                                    // and move the files on disk to new locations in the
                                    // Scraps folder
                                    NSMutableArray* updatedAllScrapProperties = [NSMutableArray array];
                                    for(NSDictionary* properties in [originalScrapPlist objectForKey:@"allScrapProperties"]){
                                        NSError* err = nil;
                                        // find new UUIDs
                                        NSString* oldScrapUUID = [properties objectForKey:@"uuid"];
                                        NSString* updatedScrapUUID = [NSString createStringUUID];
                                        
                                        // updated property list
                                        NSMutableDictionary* updatedProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
                                        [updatedProperties setObject:updatedScrapUUID forKey:@"uuid"];
                                        [updatedAllScrapProperties addObject:updatedProperties];
                                        
                                        // move the file
                                        NSString* oldPathOfScrap = [pathToScrapsInPage stringByAppendingPathComponent:oldScrapUUID];
                                        if([[NSFileManager defaultManager] isDirectory:oldPathOfScrap]){
                                            NSString* updatedPathOfScrap = [pathToScrapsInPage stringByAppendingPathComponent:updatedScrapUUID];
                                            [[NSFileManager defaultManager] moveItemAtPath:oldPathOfScrap
                                                                                    toPath:updatedPathOfScrap
                                                                                     error:&err];
                                            if(err){
                                                DebugLog(@"couldn't move %@ to %@", oldPathOfScrap, updatedPathOfScrap);
                                            }
                                        }
                                        
                                        // save the translation
                                        [renamedScraps setObject:updatedScrapUUID forKey:oldScrapUUID];
                                    }
                                    numberOfScrapsOnIncomingPage = [[originalScrapPlist objectForKey:@"allScrapProperties"] count];
                                    numberOfVisibleScrapsOnIncomingPage = [[originalScrapPlist objectForKey:@"scrapsOnPageIDs"] count];
                                    
                                    
                                    // update the array of UUIDs that are visible on the page
                                    NSMutableArray* updatedScrapsOnPageIDs = [NSMutableArray array];
                                    for(NSString* oldScrapUUID in [originalScrapPlist objectForKey:@"scrapsOnPageIDs"]){
                                        [updatedScrapsOnPageIDs addObject:[renamedScraps objectForKey:oldScrapUUID]];
                                    }
                                    
                                    // build a new plist for scraps on this page that
                                    // contains all the new UUIDs for the scraps
                                    NSMutableDictionary* updatedScrapPlist = [NSMutableDictionary dictionaryWithObjectsAndKeys:updatedAllScrapProperties, @"allScrapProperties",
                                                                              updatedScrapsOnPageIDs, @"scrapsOnPageIDs", nil];
                                    
                                    // now write the new plist to the page location
                                    [updatedScrapPlist writeToFile:pathToScrapsPlist atomically:YES];
                                    
                                    // remove the undo/redo history of the page
                                    NSError* err = nil;
                                    NSString* undoPlist = [[tempPathOfIncomingPage stringByAppendingPathComponent:@"undoRedo"] stringByAppendingPathExtension:@"plist"];
                                    [[NSFileManager defaultManager] removeItemAtPath:undoPlist error:&err];
                                    
                                    // remove the empty page marker, if any, of the page
                                    err = nil;
                                    NSString* emptyFile = [tempPathOfIncomingPage stringByAppendingPathComponent:@"empty"];
                                    [[NSFileManager defaultManager] removeItemAtPath:emptyFile error:&err];
                                    
                                    // add in the sender info
                                    NSString* senderInfoPlist = [[tempPathOfIncomingPage stringByAppendingPathComponent:@"sender"] stringByAppendingPathExtension:@"plist"];
                                    if(![NSKeyedArchiver archiveRootObject:message.senderInfo toFile:senderInfoPlist]){
                                        DebugLog(@"couldn't archive sender CloudKit account data");
                                    }
                                    
                                    // move the page into position
                                    NSString* documentsPath = [NSFileManager documentsPath];
                                    targetPageLocation = [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:tmpUUIDOfIncomingPage];
                                    
                                    err = nil;
                                    [[NSFileManager defaultManager] moveItemAtPath:tempPathOfIncomingPage toPath:targetPageLocation error:&err];
                                    
                                    if(!err){
                                        uuidOfIncomingPage = tmpUUIDOfIncomingPage;
                                    }else{
                                        uuidOfIncomingPage = nil;
                                        targetPageLocation = nil;
                                        DebugLog(@"couldn't move file from %@ to %@", tempPathOfIncomingPage, targetPageLocation);
                                    }
                                }else{
                                    DebugLog(@"coordinator failed to unzip %@ with file %@", message.messageRecordID, zipFileLocation);
                                    [importExportView importCoordinatorFailedPermanently:self withCode:kMPEventImportInvalidZipErrorCode];
                                    return;
                                }
                                
                                // at this point we've unzipped the file,
                                // or failed gloriously. so delete the zip.
                                NSError* err = nil;
                                [[NSFileManager defaultManager] removeItemAtPath:zipFileLocation error:&err];
                                if(err){
                                    // log general error?
                                    DebugLog(@"failed removing zip");
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    @autoreleasepool {
                                        DebugLog(@"coordinator is ready %@", message.messageRecordID);
                                        //
                                        // Step 3:
                                        // notify our view that we're ready to be shown to the user
                                        isReady = YES;
                                        [importExportView importCoordinatorIsReady:self];
                                    }
                                });
                            }else{
                                DebugLog(@"coordinator failed %@", message.messageRecordID);
                                DebugLog(@"invalid zip file");
                                DebugLog(@"zip at: %@", zipFileLocation);
                                
                                if([[NSFileManager defaultManager] fileExistsAtPath:zipFileLocation]){
                                    [importExportView importCoordinatorFailedPermanently:self withCode:kMPEventImportInvalidZipErrorCode];
#ifdef DEBUG
                                    if(zipFileLocation){
                                        NSString* savedPath = [[NSFileManager documentsPath] stringByAppendingPathComponent:[zipFileLocation lastPathComponent]];
                                        [[NSFileManager defaultManager] moveItemAtPath:zipFileLocation toPath:savedPath error:nil];
                                        DebugLog(@"saved to: %@", savedPath);
                                    }
#endif
                                }else{
                                    [importExportView importCoordinatorFailedPermanently:self withCode:kMPEventImportMissingZipErrorCode];
                                }
                            }
                        }
                    });
                }else{
                    switch (error.code) {
                        case SPRSimpleCloudMessengerErrorUnexpected:
                        case SPRSimpleCloudMessengerErrorNetwork:
                        case SPRSimpleCloudMessengerErrorServiceUnavailable:
                        case SPRSimpleCloudMessengerErrorRateLimit:
                        case SPRSimpleCloudMessengerErrorCancelled:
                            DebugLog(@"coordinator failed temporarily - couldn't fetch data %@ %@", message.messageRecordID, error);
                            DebugLog(@"retrying in 5s");
                            [self performSelector:@selector(begin) withObject:nil afterDelay:5];
                            break;
                            
                        case SPRSimpleCloudMessengerErroriCloudAccount:
                        case SPRSimpleCloudMessengerErroriCloudAccountChanged:
                        case SPRSimpleCloudMessengerErrorMissingDiscoveryPermissions:
                        default:
                            DebugLog(@"coordinator failed permanently - couldn't fetch data %@ %@", message.messageRecordID, error);
                            [importExportView importCoordinatorFailedPermanently:self withCode:error.code];
                            break;
                    }
                }
            }];
        }
    });
}

-(NSString*) uuidOfIncomingPage{
    return uuidOfIncomingPage;
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
        isReady = [[decoder decodeObjectForKey:@"isReady"] boolValue];
    }
    return self;
}


-(BOOL) matchesMessage:(SPRMessage*)otherMessage{
    return [message.messageRecordID isEqual:otherMessage.messageRecordID];
}

@end
