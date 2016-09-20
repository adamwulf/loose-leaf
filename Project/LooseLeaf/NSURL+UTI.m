//
//  NSURL+UTI.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSURL+UTI.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSURL (UTI)

+ (NSString*)UTIForExtension:(NSString*)fileExtension {
    NSString* UTI = (__bridge_transfer NSString*)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    if (!UTI) {
        UTI = @"unknown";
    }
    return [UTI lowercaseString];
}

+ (NSString*)mimeForExtension:(NSString*)fileExtension {
    NSString* UTI = [self UTIForExtension:fileExtension];
    return (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
}

- (NSString*)universalTypeID {
    return [NSURL UTIForExtension:[self fileExtension]];
}

- (NSString*)fileExtension {
    NSString* path = self.path;
    return [path.pathExtension lowercaseString];
}

- (NSString*)mimeType {
    return [NSURL mimeForExtension:[self fileExtension]];
}

@end
