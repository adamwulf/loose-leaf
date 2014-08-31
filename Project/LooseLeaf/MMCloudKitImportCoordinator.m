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
#import <ZipArchive/ZipArchive.h>

@implementation MMCloudKitImportCoordinator{
    CKDiscoveredUserInfo* senderInfo;
    MMAvatarButton* avatarButton;
    NSString* zipFileLocation;
    MMCloudKitExportView* exportView;
}

@synthesize avatarButton;

-(id) initWithSender:(CKDiscoveredUserInfo*)_senderInfo andButton:(MMAvatarButton*)_avatarButton andZipFile:(NSString*)_zipFile forExportView:(MMCloudKitExportView*)_exportView{
    if(self = [super init]){
        senderInfo = _senderInfo;
        avatarButton = _avatarButton;
        zipFileLocation = _zipFile;
        exportView = _exportView;
    }
    return self;
}

-(void) begin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // we define our own UUID for the incoming page
        NSString* uuidOfIncomingPage = [NSString createStringUUID];
        // we'll put all the files into this directory for now
        NSString* tempPathOfIncomingPage = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"IncomingPages"] stringByAppendingPathComponent:uuidOfIncomingPage];

        NSLog(@"unzipping to: %@", tempPathOfIncomingPage);
        ZipArchive* zip = [[ZipArchive alloc] init];
        if([zip unzipOpenFile:zipFileLocation]){
            // make sure target directory exists
            [[NSFileManager defaultManager] createDirectoryAtPath:tempPathOfIncomingPage withIntermediateDirectories:YES attributes:nil error:nil];
            // unzip files
            [zip unzipFileTo:tempPathOfIncomingPage overWrite:NO];
            
            NSLog(@"unzipped page: %@", tempPathOfIncomingPage);
            
            NSString* pathToScrapsInPage = [tempPathOfIncomingPage stringByAppendingPathComponent:@"Scraps"];
            NSArray* scrapContentsOfPage = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToScrapsInPage error:nil];
            
            for (NSString* path in scrapContentsOfPage) {
                NSError* err = nil;
                if([[NSFileManager defaultManager] isDirectory:path]){
                    NSString* uuidOfIncomingScrap = [NSString createStringUUID];
                    NSString* oldScrapPath = [pathToScrapsInPage stringByAppendingPathComponent:path];
                    NSString* newScrapPath = [pathToScrapsInPage stringByAppendingPathComponent:uuidOfIncomingScrap];
                    [[NSFileManager defaultManager] moveItemAtPath:oldScrapPath
                                                            toPath:newScrapPath
                                                             error:&err];
                    if(err){
                        NSLog(@"couldn't move %@ to %@", oldScrapPath, newScrapPath);
                    }
                }
            }
            if([scrapContentsOfPage count]){
                NSLog(@"need to update page scrap plist contents");
            }
        }else{
            NSLog(@"failed to unzip file: %@", zipFileLocation);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [exportView importCoordinatorIsReady:self];
        });
    });

}

@end
