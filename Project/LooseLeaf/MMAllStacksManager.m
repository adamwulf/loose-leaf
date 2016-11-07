//
//  MMAllStacksManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMAllStacksManager.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMSingleStackManager.h"
#import "NSArray+Extras.h"
#import "NSArray+Map.h"
#import "NSThread+BlockAdditions.h"
#import "MMUpgradeInProgressViewController.h"
#import "MMScrapStateUpgrader.h"
#import "MMJotViewStateUpgrader.h"


@implementation MMAllStacksManager {
    NSMutableArray* stackIDs;
    UIWindow* upgradingWindow;
}

static MMAllStacksManager* _instance = nil;

+ (void)load {
    [MMAllStacksManager sharedInstance];
}

+ (MMAllStacksManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMAllStacksManager alloc] init];
    });
    return _instance;
}

- (NSString*)stackDirectoryPathForUUID:(NSString*)uuid {
    return [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:uuid];
}

- (instancetype)init {
    if (self = [super init]) {
        stackIDs = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"]]]];

        if (!stackIDs) {
            stackIDs = [NSMutableArray array];
        }
    }
    return self;
}

- (NSArray*)stackIDs {
    CheckMainThread;
    return [stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        return obj[@"uuid"];
    }];
}

- (NSString*)nameOfStack:(NSString*)stackUUID {
    CheckMainThread;
    return [stackIDs jotReduce:^id(id obj, NSUInteger index, id accum) {
        if ([obj[@"uuid"] isEqualToString:stackUUID]) {
            return obj[@"name"];
        }
        return accum;
    }];
}

- (NSArray*)cachedPagesForStack:(NSString*)stackUUID {
    CheckMainThread;
    return [stackIDs jotReduce:^id(id obj, NSUInteger index, id accum) {
        if ([obj[@"uuid"] isEqualToString:stackUUID]) {
            return obj[@"firstPages"];
        }
        return accum;
    }];
}

- (NSString*)createStack:(BOOL)withDefaultContent {
    CheckMainThread;
    NSString* stackID = [[NSUUID UUID] UUIDString];

    NSError* err;
    NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:stackID];
    [[NSFileManager defaultManager] createDirectoryAtPath:stackDirectory withIntermediateDirectories:YES attributes:nil error:&err];

    [stackIDs addObject:@{ @"uuid": stackID }];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];

    if (!withDefaultContent) {
        NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:stackID];
        [NSFileManager ensureDirectoryExistsAtPath:stackDirectory];
        NSString* visiblePagesPlist = [[stackDirectory stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
        NSString* hiddenPagesPlist = [[stackDirectory stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];

        [@[] writeToFile:visiblePagesPlist atomically:YES];
        [@[] writeToFile:hiddenPagesPlist atomically:YES];
    }

    return stackID;
}

- (void)deleteStack:(NSString*)stackUUID {
    CheckMainThread;
    [stackIDs filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString*, id>* _Nullable bindings) {
        return ![evaluatedObject[@"uuid"] isEqualToString:stackUUID];
    }]];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSFileManager defaultManager] removeItemAtPath:[self stackDirectoryPathForUUID:stackUUID] error:nil];
    });
}

- (void)updateCachedPages:(NSArray*)pages forStackUUID:(NSString*)stackUUID {
    [NSThread performBlockOnMainThread:^{
        NSArray* allPages = pages;
        if ([allPages count]) {
            allPages = [allPages subarrayWithRange:NSMakeRange(0, MIN([allPages count], 3))];
        }
        __block BOOL didUpdateAnything = NO;
        stackIDs = [[stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            if ([obj[@"uuid"] isEqualToString:stackUUID]) {
                BOOL pagesAreDifferent = [obj[@"firstPages"] count] != [pages count];
                for (int i = 0; i < MIN([obj[@"firstPages"] count], [pages count]); i++) {
                    pagesAreDifferent = pagesAreDifferent || ![obj[@"firstPages"][i] isEqualToDictionary:pages[i]];
                }

                if (pagesAreDifferent) {
                    didUpdateAnything = YES;
                    NSMutableDictionary* mutObj = [obj mutableCopy];
                    mutObj[@"firstPages"] = allPages;
                    return mutObj;
                }
            }
            return obj;
        }] mutableCopy];
        if (didUpdateAnything) {
            [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StackCachedPagesDidUpdateNotification" object:nil userInfo:@{ @"stackUUID": stackUUID }];
        }
    }];
}

- (void)updateName:(NSString*)name forStack:(NSString*)stackUUID {
    [NSThread performBlockOnMainThread:^{
        __block BOOL didUpdateAnything = NO;
        stackIDs = [[stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            if ([obj[@"uuid"] isEqualToString:stackUUID]) {
                if (![obj[@"name"] isEqualToString:name]) {
                    didUpdateAnything = YES;
                    NSMutableDictionary* mutObj = [obj mutableCopy];
                    mutObj[@"name"] = name;
                    return mutObj;
                }
            }
            return obj;
        }] mutableCopy];
        if (didUpdateAnything) {
            [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StackCachedPagesDidUpdateNotification" object:nil userInfo:@{ @"stackUUID": stackUUID }];
        }
    }];
}

#pragma mark - Upgrade to 2.0.0

- (void)upgradeIfNecessary:(void (^)())upgradeCompleteBlock {
    // upgrade to multiple stacks UI
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kIsShowingListView] || ![[NSUserDefaults standardUserDefaults] objectForKey:kCurrentViewMode]) {
        [[NSUserDefaults standardUserDefaults] setObject:kViewModeCollapsed forKey:kCurrentViewMode];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsShowingListView];
    }

    // upgrade to multiple stacks file system
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* visiblePagesPlist = [[documentsPath stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
    NSString* hiddenPagesPlist = [[documentsPath stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
    NSString* pagesDir = [documentsPath stringByAppendingPathComponent:@"Pages"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:visiblePagesPlist] &&
        [[NSFileManager defaultManager] fileExistsAtPath:hiddenPagesPlist] &&
        [[NSFileManager defaultManager] fileExistsAtPath:pagesDir]) {
        MMUpgradeInProgressViewController* progressController = [[MMUpgradeInProgressViewController alloc] init];
        upgradingWindow = [[UIWindow alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
        upgradingWindow.rootViewController = progressController;
        [upgradingWindow makeKeyAndVisible];

        // upgrade from 1.x to 2.x required
        stackIDs = stackIDs ?: [NSMutableArray array];
        NSString* stackID = [self createStack:NO];
        NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:stackID];


        void (^moveFilesIntoPlace)() = ^{

            [[NSFileManager defaultManager] moveItemAtPath:visiblePagesPlist toPath:[stackDirectory stringByAppendingPathComponent:[visiblePagesPlist lastPathComponent]] error:nil];
            [[NSFileManager defaultManager] moveItemAtPath:hiddenPagesPlist toPath:[stackDirectory stringByAppendingPathComponent:[hiddenPagesPlist lastPathComponent]] error:nil];
            [[NSFileManager defaultManager] moveItemAtPath:pagesDir toPath:[stackDirectory stringByAppendingPathComponent:[pagesDir lastPathComponent]] error:nil];

            // show a upgrade complete message for 1s
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                upgradeCompleteBlock();

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    upgradingWindow = nil;
                });
            });
        };


        void (^upgradeStrokesAndScrapsForAllPages)() = ^{
            __block NSInteger numberOfPagesUpgraded = 0;

            [[NSFileManager defaultManager] enumerateDirectory:pagesDir withBlock:^(NSURL* item, NSUInteger totalItemCount) {

                MMJotViewStateUpgrader* scrapUpgrader = [[MMJotViewStateUpgrader alloc] initWithPagesPath:[item path]];
                MMScrapStateUpgrader* strokeUpgrader = [[MMScrapStateUpgrader alloc] initWithPagesPath:[item path]];

                void (^completionCheck)() = ^{
                    numberOfPagesUpgraded += 1;

                    [progressController setProgress:(CGFloat)numberOfPagesUpgraded / (2.0 * totalItemCount)];

                    // check multiply by 2 because we upgrade 2 things per page
                    if (totalItemCount * 2 == numberOfPagesUpgraded) {
                        // finished upgrading all page's scraps
                        moveFilesIntoPlace();
                    }
                };

                [strokeUpgrader upgradeWithCompletionBlock:completionCheck];
                [scrapUpgrader upgradeWithCompletionBlock:completionCheck];

            } andErrorHandler:nil];
        };

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            upgradeStrokesAndScrapsForAllPages();
        });
    } else {
        upgradeCompleteBlock();
    }
}

@end
