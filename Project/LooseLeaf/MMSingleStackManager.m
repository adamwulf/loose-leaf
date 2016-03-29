//
//  MMSingleStackManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSingleStackManager.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Map.h"
#import "MMBlockOperation.h"
#import "MMExportablePaperView.h"
#import "Mixpanel.h"
#import "NSString+UUID.h"
#import "NSArray+Extras.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMAllStacksManager.h"

@implementation MMSingleStackManager

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

-(NSString*) visiblePlistPath{
    return [MMSingleStackManager visiblePlistPathForStackUUID:self.uuid];
}

-(NSString*) hiddenPlistPath{
    return [MMSingleStackManager hiddenPlistPathForStackUUID:self.uuid];
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
    NSDictionary* plist = [MMSingleStackManager loadFromDiskForStackUUID:self.uuid];
    
    //    DebugLog(@"starting up with %d visible and %d hidden", (int)[visiblePagesToCreate count], (int)[hiddenPagesToCreate count]);
    
    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];
    
    int hasFoundDuplicate = 0;
    NSMutableSet* seenPageUUIDs = [NSMutableSet set];
    
    for(NSDictionary* pageDict in plist[@"visiblePages"]){
        NSString* pageuuid = [pageDict objectForKey:@"uuid"];
        if(![seenPageUUIDs containsObject:pageuuid]){
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageuuid];
            [visiblePages addObject:page];
            [seenPageUUIDs addObject:pageuuid];
        }else{
            DebugLog(@"found duplicate page: %@", pageuuid);
            hasFoundDuplicate++;
        }
    }
    
    for(NSDictionary* pageDict in plist[@"hiddenPages"]){
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
    
    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePages, @"visiblePages",
            hiddenPages, @"hiddenPages", nil];
}

#pragma mark - Class methods

+(NSString*) visiblePlistPathForStackUUID:(NSString*)stackUUID{
    return [[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID] stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
}

+(NSString*) hiddenPlistPathForStackUUID:(NSString*)stackUUID{
    return [[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID] stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
}

+(NSDictionary*) loadFromDiskForStackUUID:(NSString*)stackUUID{
    NSArray* visiblePagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self visiblePlistPathForStackUUID:stackUUID]];
    NSArray* hiddenPagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self hiddenPlistPathForStackUUID:stackUUID]];

    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePagesToCreate, @"visiblePages",
            hiddenPagesToCreate, @"hiddenPages", nil];
}

@end
