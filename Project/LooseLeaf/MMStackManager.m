//
//  MMStackManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMStackManager.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Map.h"
#import "MMBlockOperation.h"
#import "MMExportablePaperView.h"
#import "Mixpanel.h"
#import "NSString+UUID.h"
#import "NSArray+Extras.h"
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMStackManager

@synthesize uuid;

-(id) initWithUUID:(NSString*)_uuid visibleStack:(UIView*)_visibleStack andHiddenStack:(UIView*)_hiddenStack andBezelStack:(UIView*)_bezelStack{
    if(self = [super init]){
        uuid = _uuid;
        visibleStack = _visibleStack;
        hiddenStack = _hiddenStack;
        bezelStack = _bezelStack;
        
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(NSString*) stackDirectoryPath{
    return [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:self.uuid];
}

-(NSString*) visiblePlistPath{
    return [[[self stackDirectoryPath] stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
}

-(NSString*) hiddenPlistPath{
    return [[[self stackDirectoryPath] stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
}


-(void) saveStacksToDisk{
    [NSThread performBlockOnMainThread:^{
        // must use main thread to get the stack
        // of UIViews to save to disk
        
        NSArray* visiblePages = [NSArray arrayWithArray:visibleStack.subviews];
        NSMutableArray* hiddenPages = [NSMutableArray arrayWithArray:hiddenStack.subviews];
        NSMutableArray* bezelPages = [NSMutableArray arrayWithArray:bezelStack.subviews];
        while([bezelPages count]){
            id obj = [bezelPages lastObject];
            [hiddenPages addObject:obj];
            [bezelPages removeLastObject];
        }
        
        [opQueue addOperation:[[MMBlockOperation alloc] initWithBlock:^{
            // now that we have the views to save,
            // we can actually write to disk on the background
            //
            // the opqueue makes sure that we will always save
            // to disk in the order that [saveToDisk] was called
            // on the main thread.
            NSArray* visiblePagesToWrite = [visiblePages mapObjectsUsingSelector:@selector(dictionaryDescription)];
            NSArray* hiddenPagesToWrite = [hiddenPages mapObjectsUsingSelector:@selector(dictionaryDescription)];
            
            [visiblePagesToWrite writeToFile:[self visiblePlistPath] atomically:YES];
            [hiddenPagesToWrite writeToFile:[self hiddenPlistPath] atomically:YES];
        }]];
    }];
}

-(BOOL) hasStateToLoad{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self visiblePlistPath]];
}

-(NSDictionary*) loadFromDiskWithBounds:(CGRect)bounds{
    
    NSArray* visiblePagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self visiblePlistPath]];
    NSArray* hiddenPagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self hiddenPlistPath]];
    
//    DebugLog(@"starting up with %d visible and %d hidden", (int)[visiblePagesToCreate count], (int)[hiddenPagesToCreate count]);

    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];
    
    int hasFoundDuplicate = 0;
    NSMutableSet* seenPageUUIDs = [NSMutableSet set];
    
    for(NSDictionary* pageDict in visiblePagesToCreate){
        NSString* pageuuid = [pageDict objectForKey:@"uuid"];
        if(![seenPageUUIDs containsObject:pageuuid]){
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageuuid];
            [visiblePages addObject:page];
            [seenPageUUIDs addObject:pageuuid];
            //
            //
            //
            // duplicate the page
//#ifdef DEBUG
//            NSString* pathOfPage = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Pages"]stringByAppendingPathComponent:uuid];
//            // create new page uuid
//            uuid = [NSString createStringUUID];
//            NSString* duplicatePagePath = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Pages"]stringByAppendingPathComponent:uuid];
//            [[NSFileManager defaultManager] copyItemAtPath:pathOfPage toPath:duplicatePagePath error:nil];
//            // create the new page object
//            page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:uuid];
//            [visiblePages addObject:page];
//            [seenPageUUIDs addObject:uuid];
//#endif
            //
            //
        }else{
            DebugLog(@"found duplicate page: %@", pageuuid);
            hasFoundDuplicate++;
        }
    }
    
    for(NSDictionary* pageDict in hiddenPagesToCreate){
        NSString* pageuuid = [pageDict objectForKey:@"uuid"];
        if(![seenPageUUIDs containsObject:pageuuid]){
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageuuid];
            [hiddenPages addObject:page];
            [seenPageUUIDs addObject:pageuuid];
        }else{
            DebugLog(@"found duplicate page: %@", pageuuid);
            hasFoundDuplicate++;
        }
    }
    
    if(hasFoundDuplicate){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfDuplicatePages by:@(hasFoundDuplicate)];
    }
    
//    DebugLog(@"loaded %d and %d",(int) [visiblePages count],(int) [hiddenPages count]);

//#ifdef DEBUG
//    [visiblePages shuffle];
//    [hiddenPages shuffle];
//#endif
    
    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePages, @"visiblePages",
            hiddenPages, @"hiddenPages", nil];
}

@end
