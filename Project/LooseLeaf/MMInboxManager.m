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

@implementation MMInboxManager

static MMInboxManager* _instance = nil;

+(MMInboxManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMInboxManager alloc]init];
    }
    return _instance;
}


+(NSString*) UTIForExtension:(NSString*)fileExtension{
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    if(!UTI){
        UTI = @"unknown";
    }
    return [UTI lowercaseString];
}

-(UIImage*) imageForURL:(NSURL*)url maxDim:(int)maxDim{
    
    NSString* filePath = [url.path lowercaseString];
    if([filePath.pathExtension isEqualToString:@"icns"]){
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

- (void)removeInboxItem:(NSURL *)itemURL
{
    //Clean up the inbox once the file has been processed
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[itemURL path] error:&error];
    
    if (error) {
        NSLog(@"ERROR: Inbox file could not be deleted");
    }
}

@end
