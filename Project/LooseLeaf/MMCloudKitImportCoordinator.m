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
#import "MMCloudKitExportView.h"
#import "SPRMessage+Initials.h"
#import <ZipArchive/ZipArchive.h>
#import "Mixpanel.h"

@implementation MMCloudKitImportCoordinator{
    MMAvatarButton* avatarButton;
    NSString* zipFileLocation;
    MMCloudKitExportView* exportView;
    
    // nil if the scrap unzip failed, or if
    // the coordinator hasn't begun
    NSString* uuidOfIncomingPage;
    NSString* targetPageLocation;
    NSInteger numberOfScrapsOnIncomingPage; // used for mixpanel only
    NSInteger numberOfVisibleScrapsOnIncomingPage; // used for mixpanel only
}

@synthesize avatarButton;
@synthesize isReady;

-(id) initWithImport:(SPRMessage*)importInfo forExportView:(MMCloudKitExportView*)_exportView{
    if(self = [super init]){
        zipFileLocation = importInfo.messageData.path;
        exportView = _exportView;
        avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:importInfo.initials];
        [avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) begin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
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
                        NSLog(@"couldn't move %@ to %@", oldPathOfScrap, updatedPathOfScrap);
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
                NSLog(@"couldn't move file from %@ to %@", tempPathOfIncomingPage, targetPageLocation);
            }
        }else{
            NSLog(@"failed to unzip file: %@", zipFileLocation);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isReady = YES;
            [exportView importCoordinatorIsReady:self];
        });
    });
}

-(NSString*) uuidOfIncomingPage{
    return uuidOfIncomingPage;
}

#pragma mark - Touch Event

-(void) avatarButtonTapped:(MMAvatarButton*)button{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfImports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCloudKitImports by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventImportPage properties:@{kMPEventImportPropScrapCount : @(numberOfScrapsOnIncomingPage),
                                                                      kMPEventImportPropVisibleScrapCount : @(numberOfVisibleScrapsOnIncomingPage)}];
    
    [exportView importWasTapped:self];
}


@end
