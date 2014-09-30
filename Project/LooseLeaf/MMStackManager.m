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
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMStackManager

-(id) initWithVisibleStack:(MMPaperStackView*)_visibleStack andHiddenStack:(MMPaperStackView*)_hiddenStack andBezelStack:(MMPaperStackView*)_bezelStack{
    if(self = [super init]){
        visibleStack = _visibleStack;
        hiddenStack = _hiddenStack;
        bezelStack = _bezelStack;
        
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(NSString*) visiblePlistPath{
    NSString* documentsPath = [NSFileManager documentsPath];
    return [[documentsPath stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
}

-(NSString*) hiddenPlistPath{
    NSString* documentsPath = [NSFileManager documentsPath];
    return [[documentsPath stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
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

-(NSDictionary*) loadFromDiskWithBounds:(CGRect)bounds{
    
    NSArray* visiblePagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self visiblePlistPath]];
    NSArray* hiddenPagesToCreate = [[NSArray alloc] initWithContentsOfFile:[self hiddenPlistPath]];
    
    debug_NSLog(@"starting up with %d visible and %d hidden", (int)[visiblePagesToCreate count], (int)[hiddenPagesToCreate count]);

    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];
    
    int hasFoundDuplicate = 0;
    NSMutableSet* seenPageUUIDs = [NSMutableSet set];
    
    for(NSDictionary* pageDict in visiblePagesToCreate){
        NSString* uuid = [pageDict objectForKey:@"uuid"];
        if(![seenPageUUIDs containsObject:uuid]){
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:uuid];
            [visiblePages addObject:page];
            [seenPageUUIDs addObject:uuid];
        }else{
            NSLog(@"found duplicate page: %@", uuid);
            hasFoundDuplicate++;
        }
    }
    
    for(NSDictionary* pageDict in hiddenPagesToCreate){
        NSString* uuid = [pageDict objectForKey:@"uuid"];
        if(![seenPageUUIDs containsObject:uuid]){
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:uuid];
            [hiddenPages addObject:page];
            [seenPageUUIDs addObject:uuid];
        }else{
            NSLog(@"found duplicate page: %@", uuid);
            hasFoundDuplicate++;
        }
    }
    
    if(hasFoundDuplicate){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfDuplicatePages by:@(hasFoundDuplicate)];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePages, @"visiblePages",
            hiddenPages, @"hiddenPages", nil];
}

@end
