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


- (NSArray *)recursiveContentsOfDirectoryAtPath:(NSString *)directoryPath filesOnly:(BOOL)filesOnly{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [self enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    BOOL isDirectory = NO;
    while ((filePath = [enumerator nextObject]) != nil){
        [self fileExistsAtPath:[directoryPath stringByAppendingPathComponent:filePath] isDirectory:&isDirectory];
        if(!filePath || !isDirectory){
            [filePaths addObject:filePath];
        }
    }
    return filePaths;
}

-(BOOL) isDirectory:(NSString*)path{
    BOOL isDirectory = NO;
    BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory && exists;
}

-(NSString*) humanReadableSizeForItemAtPath:(NSString *)path{
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attribs) {
        return [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    }
    return @"Unknown";
}

-(unsigned long long) sizeForItemAtPath:(NSString *)path{
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attribs) {
        return [attribs fileSize];
    }
    return 0;
}

@end
