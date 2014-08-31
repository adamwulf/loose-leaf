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
#import <ZipArchive/ZipArchive.h>

@implementation MMCloudKitImportCoordinator{
    CKDiscoveredUserInfo* senderInfo;
    MMAvatarButton* avatarButton;
    NSString* zipFileLocation;
}

-(id) initWithSender:(CKDiscoveredUserInfo*)_senderInfo andButton:(MMAvatarButton*)_avatarButton andZipFile:(NSString*)_zipFile{
    if(self = [super init]){
        senderInfo = _senderInfo;
        avatarButton = _avatarButton;
        zipFileLocation = _zipFile;
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
            
            NSArray* contentsOfPage = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:tempPathOfIncomingPage filesOnly:YES];
            
            NSLog(@"contents: %@", contentsOfPage);
            
        }else{
            NSLog(@"failed to unzip file: %@", zipFileLocation);
        }
    });

}

@end
