//
//  MMExportablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMExportablePaperView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import <ZipArchive/ZipArchive.h>


@implementation MMExportablePaperView{
    BOOL isCurrentlyExporting;
    BOOL isCurrentlySaving;
    BOOL waitingForExport;
    BOOL waitingForSave;
}


-(void) saveToDisk{
    @synchronized(self){
        if(isCurrentlySaving || isCurrentlyExporting){
            NSLog(@"waiting to save page");
            waitingForSave = YES;
            return;
        }
        NSLog(@"begining saving page");
        isCurrentlySaving = YES;
        waitingForSave = NO;
    }
    [super saveToDisk];
}

-(void) saveToDisk:(void (^)(BOOL))onComplete{
    [super saveToDisk:^(BOOL hadEditsToSave){
        @synchronized(self){
            isCurrentlySaving = NO;
            NSLog(@"ending saving page %d", hadEditsToSave);
            [self retrySaveOrExport];
        }
        if(onComplete) onComplete(hadEditsToSave);
    }];
}

-(void) retrySaveOrExport{
    if(waitingForSave){
        NSLog(@"retrying to save page");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveToDisk];
        });
    }else if(waitingForExport){
        NSLog(@"retrying to export page");
        [self exportAsynchronouslyToZipFile];
    }
}

-(void) exportAsynchronouslyToZipFile{
    @synchronized(self){
        if(isCurrentlySaving || isCurrentlyExporting){
            NSLog(@"waiting to export page");
            waitingForExport = YES;
            return;
        }
        NSLog(@"begining export page");
        isCurrentlyExporting = YES;
        waitingForExport = NO;
    }
    
    dispatch_async([self serialBackgroundQueue], ^{
        sleep(3);
        
        NSString* generatedZipFile = [self generateZipFile];
        
        @synchronized(self){
            isCurrentlyExporting = NO;
            NSLog(@"ending export page");
            [self.delegate didExportPage:self toZipLocation:generatedZipFile];
            [self retrySaveOrExport];
        }
    });
}



-(NSString*) generateZipFile{
    
    NSString* pathOfPageFiles = [self pagesPath];
    
    NSUInteger hash1 = self.paperState.lastSavedUndoHash;
    NSUInteger hash2 = self.scrapsOnPaperState.lastSavedUndoHash;
    NSString* zipFileName = [NSString stringWithFormat:@"%@%lu%lu.zip", self.uuid, (unsigned long)hash1, (unsigned long)hash2];
    
    
    
    
    NSArray * directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:pathOfPageFiles filesOnly:YES];
    NSLog(@"wants to zip: %@", directoryContents);
    
    NSString* fullPathToZip = [NSTemporaryDirectory() stringByAppendingPathComponent:zipFileName];
    NSLog(@"creating zip file at: %@", fullPathToZip);
    
    
    // File Tobe Added in Zip
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    if([zip createZipFileAt:fullPathToZip])
    {
        NSLog(@"Zip File Created");
        if([zip addFileToZip:filePath toPathInZip:[NSString stringWithFormat:@"%@",[filePath lastPathComponent]]])
        {
            NSLog(@"File Added to zip");
        }
        [zip closeZipFile];
    }
    
    NSLog(@"success? %d", [[NSFileManager defaultManager] fileExistsAtPath:fullPathToZip]);
    
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToZip error:nil];
    if (attribs) {
        NSLog(@"zip file is %@", [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile]);
    }
    
    return fullPathToZip;
}


@end
