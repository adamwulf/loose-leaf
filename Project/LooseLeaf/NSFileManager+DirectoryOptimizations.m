//
//  NSFileManager+DirectoryOptimizations.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSFileManager+DirectoryOptimizations.h"
#import "NSThread+BlockAdditions.h"
#import <DrawKit-iOS/JRSwizzle.h>
#import "NSMutableSet+Extras.h"
#import <JotUI/JotUI.h>

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
    if(!path) return;
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

-(BOOL) swizzle_removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error{
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForPath:path];
    @synchronized(pathCacheDictionary){
        [pathCacheDictionary removeObject:path];
        [pathCacheDictionary filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![evaluatedObject hasPrefix:path];
        }]];
    }
    return [self swizzle_removeItemAtPath:path error:error];
}


-(void) preCacheDirectoryListingAt:(NSString*)directoryToScan{
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForDirectory:directoryToScan];
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
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForDirectory:directoryPath];

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
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForPath:path];
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attribs) {
        return [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    }
    return @"Unknown";
}

-(unsigned long long) sizeForItemAtPath:(NSString *)path{
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForPath:path];
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attribs) {
        return [attribs fileSize];
    }
    return 0;
}

-(BOOL) swizzle_fileExistsAtPath:(NSString *)path{
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForPath:path];
    return [self swizzle_fileExistsAtPath:path];
}

-(BOOL) swizzle_fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory{
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForPath:path];
    return [self swizzle_fileExistsAtPath:path isDirectory:isDirectory];
}


+(void)load{
    NSError *error = nil;
    [NSFileManager jr_swizzleMethod:@selector(removeItemAtPath:error:)
                         withMethod:@selector(swizzle_removeItemAtPath:error:)
                              error:&error];
    [NSFileManager jr_swizzleMethod:@selector(fileExistsAtPath:)
                         withMethod:@selector(swizzle_fileExistsAtPath:)
                              error:&error];
    [NSFileManager jr_swizzleMethod:@selector(fileExistsAtPath:isDirectory:)
                         withMethod:@selector(swizzle_fileExistsAtPath:isDirectory:)
                              error:&error];
}

@end
