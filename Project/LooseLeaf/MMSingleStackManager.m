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
#import "NSArray+Extras.h"
#import <JotUI/UIImage+Alpha.h>
#import "NSArray+MapReduce.h"


@implementation MMSingleStackManager {
    BOOL isLoaded;
}

@synthesize uuid;

- (id)initWithUUID:(NSString*)_uuid visibleStack:(UIView*)_visibleStack andHiddenStack:(UIView*)_hiddenStack andBezelStack:(UIView*)_bezelStack {
    if (self = [super init]) {
        uuid = _uuid;
        visibleStack = _visibleStack;
        hiddenStack = _hiddenStack;
        bezelStack = _bezelStack;

        NSString* pagesPath = [[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:uuid] stringByAppendingPathComponent:@"Pages"];
        [NSFileManager ensureDirectoryExistsAtPath:pagesPath];

        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)setName:(NSString*)name {
    if (!isLoaded) {
        return;
    }

    _name = name ?: @"";

    [NSThread performBlockOnMainThread:^{
        [opQueue addOperation:[[MMBlockOperation alloc] initWithBlock:^{
            [@{ @"name": self.name } writeToFile:[self propertiesPlistPath] atomically:YES];
        }]];
    }];
}

- (NSString*)propertiesPlistPath {
    return [MMSingleStackManager propertiesPlistPathForStackUUID:self.uuid];
}

- (NSString*)visiblePlistPath {
    return [MMSingleStackManager visiblePlistPathForStackUUID:self.uuid];
}

- (NSString*)hiddenPlistPath {
    return [MMSingleStackManager hiddenPlistPathForStackUUID:self.uuid];
}

- (void)saveStacksToDisk {
    if (!isLoaded) {
        return;
    }
    [NSThread performBlockOnMainThread:^{
        // must use main thread to get the stack
        // of UIViews to save to disk

        NSArray* visiblePages = [NSArray arrayWithArray:visibleStack.subviews];
        NSMutableArray* hiddenPages = [NSMutableArray arrayWithArray:hiddenStack.subviews];
        NSMutableArray* bezelPages = [NSMutableArray arrayWithArray:bezelStack.subviews];
        while ([bezelPages count]) {
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

            NSArray* allPagesToWrite = [visiblePagesToWrite arrayByAddingObjectsFromArray:[hiddenPagesToWrite reversedArray]];

            [[MMAllStacksManager sharedInstance] updateCachedPages:allPagesToWrite forStackUUID:uuid];

            [@{ @"name": self.name } writeToFile:[self propertiesPlistPath] atomically:YES];
            [visiblePagesToWrite writeToFile:[self visiblePlistPath] atomically:YES];
            [hiddenPagesToWrite writeToFile:[self hiddenPlistPath] atomically:YES];
        }]];
    }];
}

- (BOOL)hasStateToLoad {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self visiblePlistPath]];
}

- (NSDictionary*)loadFromDiskWithBounds:(CGRect)bounds ignoringMeta:(NSArray*)pagesMetaToIgnore {
    isLoaded = YES;

    NSDictionary* plist = [MMSingleStackManager loadFromDiskForStackUUID:self.uuid];

    NSArray* allPagesToWrite = [plist[@"visiblePages"] arrayByAddingObjectsFromArray:[plist[@"hiddenPages"] reversedArray]];
    [[MMAllStacksManager sharedInstance] updateCachedPages:allPagesToWrite forStackUUID:uuid];

    _name = plist[@"properties"][@"name"];

    //    DebugLog(@"starting up with %d visible and %d hidden", (int)[visiblePagesToCreate count], (int)[hiddenPagesToCreate count]);

    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];

    int hasFoundDuplicate = 0;
    NSMutableSet* seenPageUUIDs = [NSMutableSet set];

    for (NSDictionary* pageDict in plist[@"visiblePages"]) {
        NSString* pageuuid = [pageDict objectForKey:@"uuid"];
        if (![seenPageUUIDs containsObject:pageuuid]) {
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageuuid];
            [visiblePages addObject:page];
            [seenPageUUIDs addObject:pageuuid];
        } else {
            DebugLog(@"found duplicate page: %@", pageuuid);
            hasFoundDuplicate++;
        }
    }

    for (NSDictionary* pageDict in plist[@"hiddenPages"]) {
        NSString* pageuuid = [pageDict objectForKey:@"uuid"];
        if (![seenPageUUIDs containsObject:pageuuid]) {
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageuuid];
            [hiddenPages addObject:page];
            [seenPageUUIDs addObject:pageuuid];
        } else {
            DebugLog(@"found duplicate page: %@", pageuuid);
            hasFoundDuplicate++;
        }
    }

    BOOL (^pageExists)(NSString*) = ^BOOL(NSString* pageUUID) {
        __block BOOL existsInStack = NO;
        [[visiblePages arrayByAddingObjectsFromArray:hiddenPages] enumerateObjectsUsingBlock:^(MMPaperView* page, NSUInteger idx, BOOL * _Nonnull stop) {
            existsInStack = existsInStack || [page.uuid isEqualToString:pageUUID];
            *stop = existsInStack;
        }];
        
        if(!existsInStack){
            existsInStack = [pagesMetaToIgnore reduceToBool:^BOOL(NSDictionary* obj, NSUInteger index, BOOL accum) {
                BOOL matchesStack = [obj[@"stackUUID"] isEqualToString:self.uuid];
                BOOL matchesPage = [obj[@"uuid"] isEqualToString:pageUUID];
                return (matchesStack && matchesPage) || accum;
            }];
        }
        
        return existsInStack;
    };

    NSString* stackPath = [[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:self.uuid];
    NSString* pagePath = [stackPath stringByAppendingPathComponent:@"Pages"];

    [[NSFileManager defaultManager] enumerateDirectory:pagePath withBlock:^(NSURL* item, NSUInteger totalItemCount) {
        NSString* pageUUID = [[item path] lastPathComponent];
        if (!pageExists(pageUUID)) {
            DebugLog(@"found orphan page: %@", pageUUID);
            pageExists(pageUUID);
            // found orphan page, restore it to the stack
            MMPaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageUUID];
            [hiddenPages insertObject:page atIndex:0];
        }
    } andErrorHandler:^BOOL(NSURL* url, NSError* error) {
        return YES;
    }];

    if (hasFoundDuplicate) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfDuplicatePages by:@(hasFoundDuplicate)];
    }

    if (!plist[@"properties"][@"name"] || hasFoundDuplicate) {
        [self saveStacksToDisk];
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePages, @"visiblePages",
                                                      hiddenPages, @"hiddenPages",
                                                      _name, @"name", nil];
}

#pragma mark - Class methods

+ (NSString*)propertiesPlistPathForStackUUID:(NSString*)stackUUID {
    return [[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID] stringByAppendingPathComponent:@"properties"] stringByAppendingPathExtension:@"plist"];
}

+ (NSString*)visiblePlistPathForStackUUID:(NSString*)stackUUID {
    return [[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID] stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
}

+ (NSString*)hiddenPlistPathForStackUUID:(NSString*)stackUUID {
    return [[[[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID] stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
}

+ (NSDictionary*)loadFromDiskForStackUUID:(NSString*)stackUUID {
    NSDictionary* properties = [[NSDictionary alloc] initWithContentsOfFile:[MMSingleStackManager propertiesPlistPathForStackUUID:stackUUID]];
    NSArray* visiblePagesToCreate = [[NSArray alloc] initWithContentsOfFile:[MMSingleStackManager visiblePlistPathForStackUUID:stackUUID]];
    NSArray* hiddenPagesToCreate = [[NSArray alloc] initWithContentsOfFile:[MMSingleStackManager hiddenPlistPathForStackUUID:stackUUID]];

    if (!properties) {
        // initialize properties
        NSString* randomName = [[[MMSingleStackManager defaultStackNames] shuffledArray] objectAtIndex:0];
        properties = @{ @"name": randomName };
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:visiblePagesToCreate, @"visiblePages",
                                                      hiddenPagesToCreate, @"hiddenPages",
                                                      properties, @"properties", nil];
}

+ (UIImage*)hasThumbail:(BOOL*)thumbExists forPage:(NSString*)pageUUID forStack:(NSString*)stackUUID {
    NSString* stackPath = [[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID];
    NSString* pagePath = [[stackPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:pageUUID];
    NSString* thumbPath = [pagePath stringByAppendingPathComponent:@"scrapped.thumb.png"];

    NSString* bundledDocsPath = [[NSBundle mainBundle] pathForResource:@"Documents" ofType:nil];
    NSString* bundledPagePath = [[bundledDocsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:pageUUID];
    NSString* bundledThumbPath = [bundledPagePath stringByAppendingPathComponent:@"scrapped.thumb.png"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath] || [[NSFileManager defaultManager] fileExistsAtPath:bundledThumbPath]) {
        UIImage* thumb = [UIImage imageWithContentsOfFile:thumbPath];
        if (!thumb) {
            thumb = [UIImage imageWithContentsOfFile:bundledThumbPath];
        }
        if (thumb) {
            *thumbExists = YES;
            return thumb;
        } else {
            *thumbExists = YES;
            return nil;
        }
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:pagePath]) {
        *thumbExists = YES;
        return nil;
    } else {
        *thumbExists = NO;
        return nil;
    }
    *thumbExists = NO;
    return nil;
}

+ (NSArray<NSString*>*)defaultStackNames {
    return @[@"My Notes",
             @"A Few Quick Notes",
             @"My Notebook",
             @"Ideas and Sketches",
             @"Brainstorm Session",
             @"Top Secret Ideas",
             @"My Plan to Take Over the World",
             @"Quick Thoughts and Notes",
             @"The Next Big Thing",
             @"Project Notes",
             @"Project Specs",
             @"Meeting Minutes",
             @"Fun Ideas",
             @"The Best Laid Plans",
             @"Daily Journal",
             @"Lists of Lists",
             @"Chess Championship Strategies",
             @"Math Championship Strategies",
             @"Spaceship Design",
             @"Moonbase Design",
             @"Mars Mission Directive",
             @"Orbital Mechanics Calculations",
             @"Space Station Repair Guide",
             @"Spaceship Registration Log",
             @"Pluto is a Planet Thesis",
             @"Autobiography: Chapter 1",
             @"Robot Construction Plans",
             @"Robot Overlord Negotiations",
             @"Autonomous Robot Design Plans"];
}

@end
