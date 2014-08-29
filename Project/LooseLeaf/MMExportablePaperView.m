//
//  MMExportablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMExportablePaperView.h"
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
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dPath = [paths objectAtIndex:0];
    
    NSString* zipfile = [dPath stringByAppendingPathComponent:@"test.zip"] ;
    
    // File Tobe Added in Zip
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GetAllCardList" ofType:@"xml"];
    
    NSString *fileName = @"MyFile"; // Your New ZipFile Name
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    if([zip createZipFileAt:zipfile])
    {
        NSLog(@"Zip File Created");
        if([zip addFileToZip:filePath toPathInZip:[NSString stringWithFormat:@"%@.%@",fileName,[[filePath lastPathComponent] pathExtension]]])
        {
            NSLog(@"File Added to zip");
        }
    }
    
    return zipfile;
}


@end
