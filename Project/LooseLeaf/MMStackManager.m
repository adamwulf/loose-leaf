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
#import "MMScrappedPaperView.h"
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


-(void) saveToDisk{
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
    
    NSLog(@"starting up with %d visible and %d hidden", [visiblePagesToCreate count], [hiddenPagesToCreate count]);

    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];
    
    for(NSDictionary* pageDict in visiblePagesToCreate){
        MMPaperView* page = [[MMScrappedPaperView alloc] initWithFrame:bounds andUUID:[pageDict objectForKey:@"uuid"]];
        [visiblePages addObject:page];
    }
    
    for(NSDictionary* pageDict in hiddenPagesToCreate){
        MMPaperView* page = [[MMScrappedPaperView alloc] initWithFrame:bounds andUUID:[pageDict objectForKey:@"uuid"]];
        [hiddenPages addObject:page];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePages, @"visiblePages",
            hiddenPages, @"hiddenPages", nil];
}

@end
