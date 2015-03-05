//
//  MMImageImporter.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxManager.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSURL+UTI.h"
#import "MMPDF.h"
#import "Constants.h"
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMInboxManager{
    NSString* pdfInboxFolderPath;
    NSMutableArray* contents;
}

@synthesize delegate;

static MMInboxManager* _instance = nil;

+(MMInboxManager*) sharedInstance{
    if(!_instance){
        _instance = [[MMInboxManager alloc]init];
    }
    return _instance;
}

-(id) init{
    if(self = [super init]){
        contents = [NSMutableArray array];
        [self loadContents];
    }
    return self;
}

-(NSString*) pdfInboxFolderPath{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* documentsPath = [NSFileManager documentsPath];
        pdfInboxFolderPath = [documentsPath stringByAppendingPathComponent:@"PDFInbox"];
        [NSFileManager ensureDirectoryExistsAtPath:pdfInboxFolderPath];
    });
    return pdfInboxFolderPath;
}

#pragma mark - Dispatch Queue

static dispatch_queue_t fileSystemQueue;

+(dispatch_queue_t) fileSystemQueue{
    if(!fileSystemQueue){
        fileSystemQueue = dispatch_queue_create("com.milestonemade.looseleaf.inboxFileSystemQueue", DISPATCH_QUEUE_SERIAL);
    }
    return fileSystemQueue;
}

#pragma mark - Public Methods


// process the item, and then remove it from disk
// if appropriate
-(void) processInboxItem:(NSURL*)itemURL fromApp:(NSString*)sourceApplication{
    NSString* uti = [itemURL universalTypeID];
    
    if(UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeImage)){
        UIImage* importedImage = [self imageForURL:itemURL maxDim:600];
        if(importedImage){
            [self.delegate didProcessIncomingImage:importedImage fromURL:itemURL fromApp:sourceApplication];
            [self removeInboxItem:itemURL];
            return;
        }
    }else if(UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypePDF)){
        DebugLog(@"PDF!");
        NSString* ourInbox = [self pdfInboxFolderPath];
        ourInbox = [ourInbox stringByAppendingPathComponent:[itemURL lastPathComponent]];
        NSURL* ourInboxURL = [[NSURL alloc] initFileURLWithPath:ourInbox];
        
        NSError* err = nil;
        [[NSFileManager defaultManager] moveItemAtURL:itemURL toURL:ourInboxURL error:&err];
        
        MMPDF* pdf = [[MMPDF alloc] initWithURL:ourInboxURL];
        [self.delegate didProcessIncomingPDF:pdf fromURL:ourInboxURL fromApp:sourceApplication];
        
        @synchronized(self){
            [contents insertObject:contents atIndex:0];
        }
        
//        if([pdf pageCount] == 1){
//            [self removeInboxItem:itemURL];
//            return;
//        }
        return;
    }
    
    [self.delegate failedToProcessIncomingURL:itemURL fromApp:sourceApplication];
    
}

// remove the item from disk on our disk queue
- (void)removeInboxItem:(NSURL *)itemURL{
    dispatch_async([MMInboxManager fileSystemQueue], ^{
        @autoreleasepool {
            //Clean up the inbox once the file has been processed
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[itemURL path] error:&error];
            
            __block MMPDF* pdfToRemove = nil;
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MMPDF* pdf = obj;
                if([[pdf urlOnDisk] isEqual:itemURL]){
                    pdfToRemove = pdf;
                }
            }];
            if(pdfToRemove){
                @synchronized(self){
                    [contents removeObject:pdfToRemove];
                }
            }
            if (error) {
                DebugLog(@"ERROR: Inbox file could not be deleted");
            }
        }
    });
}

#pragma mark - Private Helpers

-(UIImage*) imageForURL:(NSURL*)url maxDim:(int)maxDim{
    
    if([[url fileExtension] isEqualToString:@"icns"]){
        CFBooleanRef b = (__bridge CFBooleanRef)([NSNumber numberWithBool:YES]);
        NSDictionary * sourceDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)kUTTypeAppleICNS, kCGImageSourceTypeIdentifierHint,
                                     b, kCGImageSourceShouldAllowFloat, nil];
//        DebugLog(@"url of image: %@", url);
//        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)(sourceDict));
        
//        NSString* type = (__bridge NSString *)(CGImageSourceGetType (imageSource));
//        DebugLog(@"input type: %p %@", imageSource, type);
        
//        CGImageSourceStatus status = CGImageSourceGetStatus (imageSource);
//        DebugLog(@"status: %d", status);
        
//        size_t foo = CGImageSourceGetCount (imageSource);
//        DebugLog(@"size: %zu", foo);
        
        [NSDictionary dictionaryWithDictionary:sourceDict];
        
    }
    
//    DebugLog(@"url of image: %@", url);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);
    
    CGSize fullScale;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        fullScale.width = [width floatValue];
        fullScale.height = [height floatValue];
//        DebugLog(@"Image dimensions: %@ x %@ px", width, height);
        CFRelease(imageProperties);
        maxDim = MIN(MAX(fullScale.width, fullScale.height), maxDim);
    }
    
//    DebugLog(@"found max dimension: %d", maxDim);
    
    NSDictionary* d = @{(id)kCGImageSourceShouldAllowFloat: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                        (id)kCGImageSourceThumbnailMaxPixelSize: @(maxDim)};
    CGImageRef imref = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)d);
    UIImage* scrapBacking = nil;
    
    if(imref){
        // need to always import images at 1.0x scale
        scrapBacking = [UIImage imageWithCGImage:imref scale:1.0 orientation:UIImageOrientationUp];
        CFRelease(imref);
    }
    CFRelease(imageSource);
    
    return scrapBacking;
}


#pragma mark - Inbox items

-(void) loadContents{
    @synchronized(self){
        [contents removeAllObjects];
        
        NSURL* pdfInboxFolder = [[NSURL alloc] initFileURLWithPath:[self pdfInboxFolderPath]];
        NSDirectoryEnumerator* dir = [[NSFileManager defaultManager] enumeratorAtURL:pdfInboxFolder
                                                          includingPropertiesForKeys:@[NSURLPathKey]
                                                                             options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                                        errorHandler:nil];
        for (NSURL* url in [dir allObjects]) {
            [contents addObject:[[MMPDF alloc] initWithURL:url]];
        }
    }
}

-(NSInteger) itemsInInboxCount{
    return [contents count];
}

-(MMPDF*) pdfItemAtIndex:(NSInteger)idx{
    return [contents objectAtIndex:idx];
}

@end
