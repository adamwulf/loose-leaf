//
//  NSFileManager+DirectoryOptimizations.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSFileManager+DirectoryOptimizations.h"
#import "NSThread+BlockAdditions.h"

@implementation NSFileManager (DirectoryOptimizations)


static NSMutableSet* pathCacheDictionary;

+(void) makePathCacheDictionary{
    if(!pathCacheDictionary){
        pathCacheDictionary = [[NSMutableSet alloc] init];
    }
}

// checks if we've tried to create this path before,
// if so then returns immediatley.
// otherwise checks existence and creates if needed
+(void) ensureDirectoryExistsAtPath:(NSString*)path{
    [NSFileManager makePathCacheDictionary];

    BOOL contains = NO;
    @synchronized(pathCacheDictionary){
        contains = [pathCacheDictionary containsObject:path];
        if(!contains){
            [pathCacheDictionary addObject:path];
        }
    }
    if(!contains){
        NSFileManager* fm = [[NSFileManager alloc] init];
        if(![fm fileExistsAtPath:path]){
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}


-(void) preCacheDirectoryListingAt:(NSString*)directoryToScan{
    [NSFileManager makePathCacheDictionary];
    NSArray* dirContents = [self contentsOfDirectoryAtPath:directoryToScan error:nil];
    @synchronized(pathCacheDictionary){
        for (NSString *component in dirContents) {
            [pathCacheDictionary addObject:[directoryToScan stringByAppendingPathComponent:component]];
        }
    }
}


static NSArray* userDocumentsPaths;

+(NSString*) documentsPath{
    if(!userDocumentsPaths){
        userDocumentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    }
    return [userDocumentsPaths objectAtIndex:0];
}


@end
