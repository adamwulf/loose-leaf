//
//  MMExportablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMExportablePaperView.h"
#import "MMEditablePaperViewSubclass.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSString+UUID.h"
#import <ZipArchive/ZipArchive.h>


@implementation MMExportablePaperView{
    BOOL isCurrentlyExporting;
    BOOL isCurrentlySaving;
    BOOL waitingForExport;
    BOOL waitingForSave;
    NSDictionary* cloudKitSenderInfo;
}

@synthesize cloudKitSenderInfo;
@synthesize isCurrentlySaving;

#pragma mark - Saving

-(void) saveToDisk:(void (^)(BOOL didSaveEdits))onComplete{
    @synchronized(self){
        if(isCurrentlySaving || isCurrentlyExporting){
            waitingForSave = YES;
            if(onComplete) onComplete(YES);
            return;
        }
        isCurrentlySaving = YES;
        waitingForSave = NO;
    }
    [super saveToDisk:^(BOOL didSaveEdits){
        if(onComplete) onComplete(didSaveEdits);
    }];
}

-(void) saveToDiskHelper:(void (^)(BOOL))onComplete{
    __block __strong MMExportablePaperView* strongSelf = self;
    [super saveToDiskHelper:^(BOOL hadEditsToSave){
        @synchronized(self){
            isCurrentlySaving = NO;
            [strongSelf retrySaveOrExport];
            strongSelf = nil;
        }
        if(onComplete) onComplete(hadEditsToSave);
    }];
}

-(void) retrySaveOrExport{
    if(waitingForSave){
        __block __strong MMExportablePaperView* strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf saveToDisk:nil];
            strongSelf = nil;
        });
    }else if(waitingForExport){
        [self exportAsynchronouslyToZipFile];
    }
}

#pragma mark - Load and Unload

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andScale:(CGFloat)scale andContext:(JotGLContext *)context{
    [super loadStateAsynchronously:async withSize:pagePixelSize andScale:scale andContext:context];
    
    if(cloudKitSenderInfo){
        // already loaded
        return;
    }
    
    dispatch_block_t block = ^{
        cloudKitSenderInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self pagesPath] stringByAppendingPathComponent:@"sender.plist"]];
    };

    if(async){
        dispatch_async([self serialBackgroundQueue], block);
    }else{
        block();
    }
}

-(void) unloadState{
    [super unloadState];
    
    dispatch_block_t block = ^{
        cloudKitSenderInfo = nil;
    };
    
    dispatch_async([self serialBackgroundQueue], block);
}



#pragma mark - Export

-(void) exportAsynchronouslyToZipFile{
    @synchronized(self){
        if(isCurrentlySaving || isCurrentlyExporting){
            waitingForExport = YES;
            return;
        }
        isCurrentlyExporting = YES;
        waitingForExport = NO;
    }
    if([self hasEditsToSave]){
        @synchronized(self){
            // welp, we can't export yet, we need
            // to save first. so set that we're waiting
            // and save immediately
            isCurrentlyExporting = NO;
            waitingForExport = YES;
        }
        NSLog(@"saved exporing while save is still needed");
        [self saveToDisk:nil];
        return;
    }
    
    dispatch_async([self serialBackgroundQueue], ^{
        NSString* generatedZipFile = [self generateZipFile];
        
        @synchronized(self){
            isCurrentlyExporting = NO;
            if(generatedZipFile){
                [self.delegate didExportPage:self toZipLocation:generatedZipFile];
            }else{
                [self.delegate didFailToExportPage:self];
            }
            [self retrySaveOrExport];
        }
    });
}



-(NSString*) generateZipFile{
    
    NSString* pathOfPageFiles = [self pagesPath];
    
    NSUInteger hash1 = self.paperState.lastSavedUndoHash;
    NSUInteger hash2 = self.scrapsOnPaperState.lastSavedUndoHash;
    NSString* zipFileName = [NSString stringWithFormat:@"%@%lu%lu.zip", self.uuid, (unsigned long)hash1, (unsigned long)hash2];
    
    NSString* fullPathToZip = [NSTemporaryDirectory() stringByAppendingPathComponent:zipFileName];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:fullPathToZip]){
        NSString* fullPathToTempZip = [fullPathToZip stringByAppendingPathExtension:@"temp"];
        // make sure temp file is deleted
        [[NSFileManager defaultManager] removeItemAtPath:fullPathToTempZip error:nil];
        
        NSMutableArray* directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:pathOfPageFiles filesOnly:YES].mutableCopy;
        NSMutableArray* bundledContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:[self bundledPagesPath] filesOnly:YES].mutableCopy;

        [bundledContents removeObjectsInArray:directoryContents];
        NSLog(@"generating zip file for path %@", pathOfPageFiles);
        NSLog(@"contents of path %d vs %d", (int) [directoryContents count], (int) [bundledContents count]);
        
        
        // find all scrap ids that are on the page vs just in our undo history
        NSDictionary* scrapInfo =[NSDictionary dictionaryWithContentsOfFile:[self scrapIDsPath]];
        NSString* locationOfUpdatedScrapInfo = nil;
        
        if(scrapInfo){
            NSArray* allScrapIDsOnPage = [scrapInfo objectForKey:@"scrapsOnPageIDs"];
            
            // make sure to filter out scraps that are in our undo history.
            typedef BOOL (^FilterBlock)(id evaluatedObject, NSDictionary *bindings);
            FilterBlock(^filter)(NSString* basePath) = ^(NSString* basePath){
                return ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if([evaluatedObject hasSuffix:@"sender.plist"]){
                        // don't include sender information
                        return NO;
                    }else if([evaluatedObject hasSuffix:@"undoRedo.plist"]){
                        // don't include undo redo
                        return NO;
                    }else if([evaluatedObject hasPrefix:@"Scraps/"]){
                        // ensure the id is in the allowed scraps
                        NSString* scrapID = [evaluatedObject substringFromIndex:@"Scraps/".length];
                        if([scrapID containsString:@"/"]){
                            scrapID = [scrapID substringToIndex:[scrapID rangeOfString:@"/"].location];
                            if([allScrapIDsOnPage containsObject:scrapID]){
                                // noop, the scrap is good to go
                            }else{
                                // this scrap isn't visible, so filter it out
                                return NO;
                            }
                        }
                    }
                    return YES;
                };
            };
            [directoryContents filterUsingPredicate:[NSPredicate predicateWithBlock:filter(pathOfPageFiles)]];
            [bundledContents filterUsingPredicate:[NSPredicate predicateWithBlock:filter([self bundledPagesPath])]];
            
            NSArray* scrapProperties = [scrapInfo objectForKey:@"allScrapProperties"];
            scrapProperties = [scrapProperties filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [allScrapIDsOnPage containsObject:[evaluatedObject objectForKey:@"uuid"]];
            }]];
            
            NSDictionary* updatedScrapPlist = @{@"allScrapProperties" : scrapProperties,
                                                @"scrapsOnPageIDs" : allScrapIDsOnPage};
            
            locationOfUpdatedScrapInfo = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString createStringUUID]];
            [updatedScrapPlist writeToFile:locationOfUpdatedScrapInfo atomically:YES];
        }
        
        ZipArchive* zip = [[ZipArchive alloc] init];
        if([zip createZipFileAt:fullPathToTempZip])
        {
            for(int filesSoFar=0;filesSoFar<[directoryContents count];filesSoFar++){
                NSString* aFileInPage = [directoryContents objectAtIndex:filesSoFar];
                NSString* fullPathOfFile = [pathOfPageFiles stringByAppendingPathComponent:aFileInPage];
                if([aFileInPage isEqualToString:@"scrapIDs.plist"] && locationOfUpdatedScrapInfo){
                    fullPathOfFile = locationOfUpdatedScrapInfo;
                }
                if([zip addFileToZip:fullPathOfFile
                         toPathInZip:aFileInPage]){
                }else{
                    NSLog(@"error for path: %@", aFileInPage);
                }
                CGFloat percentSoFar = ((CGFloat)filesSoFar / ([directoryContents count] + [bundledContents count]));
                [self.delegate isExportingPage:self withPercentage:percentSoFar toZipLocation:fullPathToZip];
            }
            for(int filesSoFar=0;filesSoFar<[bundledContents count];filesSoFar++){
                NSString* aFileInPage = [bundledContents objectAtIndex:filesSoFar];
                NSString* fullPathOfFile = [[self bundledPagesPath] stringByAppendingPathComponent:aFileInPage];
                if([aFileInPage isEqualToString:@"scrapIDs.plist"] && locationOfUpdatedScrapInfo){
                    fullPathOfFile = locationOfUpdatedScrapInfo;
                }
                if([zip addFileToZip:fullPathOfFile
                         toPathInZip:aFileInPage]){
                }else{
                    NSLog(@"error for path: %@", aFileInPage);
                }
                CGFloat percentSoFar = ((CGFloat)filesSoFar / ([directoryContents count] + [bundledContents count]));
                [self.delegate isExportingPage:self withPercentage:percentSoFar toZipLocation:fullPathToZip];
            }
            if([directoryContents count] + [bundledContents count] == 0){
                // page is entirely blank
                // send an empty file in the zip
                NSString* emptyFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"empty"];
                [@"" writeToFile:emptyFilename atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [zip addFileToZip:emptyFilename toPathInZip:@"empty"];
            }
            [zip closeZipFile];
        }
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:fullPathToTempZip]){
            // file wasn't created
            return nil;
        }else{
            NSLog(@"success? file generated at %@", fullPathToTempZip);
            NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToTempZip error:nil];
            if (attribs) {
                NSLog(@"zip file is %@", [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile]);
            }
            
            
            NSLog(@"validating zip file");
            zip = [[ZipArchive alloc] init];
            [zip unzipOpenFile:fullPathToTempZip];
            NSArray* contents = [zip contentsOfZipFile];
            [zip unzipCloseFile];
            
            NSInteger expectedContentsCount = [directoryContents count] + [bundledContents count];
            if(expectedContentsCount == 0) expectedContentsCount = 1;
            if([contents count] > 0 && [contents count] == expectedContentsCount){
                NSLog(@"valid zip file, contents: %d", (int) [contents count]);
                [[NSFileManager defaultManager] moveItemAtPath:fullPathToTempZip toPath:fullPathToZip error:nil];
            }else{
                NSLog(@"invalid zip file: %@ vs %@", contents, directoryContents);
                [[NSFileManager defaultManager] removeItemAtPath:fullPathToTempZip error:nil];
                return nil;
            }
        }
    }else{
        NSLog(@"success? file already exists at %@", fullPathToZip);
        NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToZip error:nil];
        if (attribs) {
            NSLog(@"zip file is %@", [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile]);
        }
        NSLog(@"validating...");
        ZipArchive* zip = [[ZipArchive alloc] init];
        if([zip unzipOpenFile:fullPathToZip]){
            NSLog(@"valid");
            [zip closeZipFile];
        }else{
            NSLog(@"invalid");
            [[NSFileManager defaultManager] removeItemAtPath:fullPathToZip error:nil];
            return nil;
        }
    }
    

    
    /*
    
    NSLog(@"contents of zip: %@", contents);
    
    
    
    NSLog(@"unzipping file");
    
    NSString* unzipTargetDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"safeDir"];
    
    zip = [[ZipArchive alloc] init];
    [zip unzipOpenFile:fullPathToZip];
    [zip unzipFileTo:unzipTargetDirectory overWrite:YES];
    [zip unzipCloseFile];
    
    
    directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:unzipTargetDirectory filesOnly:YES];
    NSLog(@"unzipped: %@", directoryContents);
    */
    
    return fullPathToZip;
}

@end
