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

@implementation MMInboxManager

@synthesize delegate;

static MMInboxManager* _instance = nil;

+(MMInboxManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMInboxManager alloc]init];
    }
    return _instance;
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
        NSLog(@"PDF!");
    }
    
    [self.delegate failedToProcessIncomingURL:itemURL fromApp:sourceApplication];
    
}

// remove the item from disk on our disk queue
- (void)removeInboxItem:(NSURL *)itemURL{
    dispatch_async([MMInboxManager fileSystemQueue], ^{
        //Clean up the inbox once the file has been processed
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[itemURL path] error:&error];
        if (error) {
            NSLog(@"ERROR: Inbox file could not be deleted");
        }
    });
}

#pragma mark - Private Helpers

-(UIImage*) imageForURL:(NSURL*)url maxDim:(int)maxDim{
    
    if([[url fileExtension] isEqualToString:@"icns"]){
        CFBooleanRef b = (__bridge CFBooleanRef)([NSNumber numberWithBool:YES]);
        NSDictionary * sourceDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)kUTTypeAppleICNS, kCGImageSourceTypeIdentifierHint,
                                     b, kCGImageSourceShouldAllowFloat, nil];
        NSLog(@"url of image: %@", url);
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)(sourceDict));
        
        NSString* type = (__bridge NSString *)(CGImageSourceGetType (imageSource));
        NSLog(@"input type: %p %@", imageSource, type);
        
        CGImageSourceStatus status = CGImageSourceGetStatus (imageSource);
        NSLog(@"status: %d", status);
        
        size_t foo = CGImageSourceGetCount (imageSource);
        NSLog(@"size: %zu", foo);
        
        [NSDictionary dictionaryWithDictionary:sourceDict];
        
    }
    
    NSLog(@"url of image: %@", url);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);
    
    CGSize fullScale;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        fullScale.width = [width floatValue];
        fullScale.height = [height floatValue];
        NSLog(@"Image dimensions: %@ x %@ px", width, height);
        CFRelease(imageProperties);
        maxDim = MIN(MAX(fullScale.width, fullScale.height), maxDim);
    }
    
    NSLog(@"found max dimension: %d", maxDim);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSDictionary* d = @{(id)kCGImageSourceShouldAllowFloat: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                        (id)kCGImageSourceThumbnailMaxPixelSize: @(maxDim)};
    CGImageRef imref = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)d);
    UIImage* scrapBacking = nil;
    
    if(imref){
        scrapBacking = [UIImage imageWithCGImage:imref scale:scale orientation:UIImageOrientationUp];
        CFRelease(imref);
    }
    CFRelease(imageSource);
    
    return scrapBacking;
}


@end
