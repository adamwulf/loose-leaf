//
//  NSFileManager+DirectoryOptimizations.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DirectoryOptimizations)

+(NSString*) documentsPath;

-(void) preCacheDirectoryListingAt:(NSString*)directoryToScan;

+(void) ensureDirectoryExistsAtPath:(NSString*)path;

@end
