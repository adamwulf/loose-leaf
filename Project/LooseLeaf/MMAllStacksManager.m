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

@implementation MMAllStacksManager{
    NSMutableArray* stackIDs;
}

static MMAllStacksManager* _instance = nil;

+(void)load{
    [MMAllStacksManager sharedInstance];
}

+(MMAllStacksManager*) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMAllStacksManager alloc]init];
    });
    return _instance;
}

-(NSString*) stackDirectoryPathForUUID:(NSString*)uuid{
    return [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:uuid];
}

-(instancetype) init{
    if(self = [super init]){
        stackIDs = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"]]]];
        
        if(!stackIDs){
            stackIDs = [NSMutableArray array];
        }
        
        [self checkForUpgrade];
    }
    return self;
}

-(NSArray*)stackIDs{
    CheckMainThread;
    return [stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        return obj[@"uuid"];
    }];
}

-(NSString*) nameOfStack:(NSString*)stackUUID{
    CheckMainThread;
    return [stackIDs jotReduce:^id(id obj, NSUInteger index, id accum) {
        if([obj[@"uuid"] isEqualToString:stackUUID]){
            return obj[@"name"];
        }
        return accum;
    }];
}

-(NSArray*) cachedPagesForStack:(NSString*)stackUUID{
    CheckMainThread;
    return [stackIDs jotReduce:^id(id obj, NSUInteger index, id accum) {
        if([obj[@"uuid"] isEqualToString:stackUUID]){
            return obj[@"firstPages"];
        }
        return accum;
    }];
}

-(NSString*) createStack{
    CheckMainThread;
    NSString* uuid = [[NSUUID UUID] UUIDString];

    NSError* err;
    NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:uuid];
    [[NSFileManager defaultManager] createDirectoryAtPath:stackDirectory withIntermediateDirectories:YES attributes:nil error:&err];

    [stackIDs addObject:@{ @"uuid" : uuid }];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];

    return uuid;
}

-(void) deleteStack:(NSString*)stackUUID{
    CheckMainThread;
    [stackIDs filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject[@"uuid"] isEqualToString:stackUUID];
    }]];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSFileManager defaultManager] removeItemAtPath:[self stackDirectoryPathForUUID:stackUUID] error:nil];
    });
}

-(void) updateCachedPages:(NSArray*)pages forStackUUID:(NSString*)stackUUID{
    [NSThread performBlockOnMainThread:^{
        NSArray* allPages = pages;
        if([allPages count]){
            allPages = [allPages subarrayWithRange:NSMakeRange(0, MIN([allPages count], 3))];
        }
        __block BOOL didUpdateAnything = NO;
        stackIDs = [[stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            if([obj[@"uuid"] isEqualToString:stackUUID]){
                BOOL pagesAreDifferent = [obj[@"firstPages"] count] != [pages count];
                for (int i=0; i<MIN([obj[@"firstPages"] count], [pages count]); i++) {
                    pagesAreDifferent = pagesAreDifferent || ![obj[@"firstPages"][i] isEqualToDictionary:pages[i]];
                }
                
                if(pagesAreDifferent){
                    didUpdateAnything = YES;
                    NSMutableDictionary* mutObj = [obj mutableCopy];
                    mutObj[@"firstPages"] = allPages;
                    return mutObj;
                }
            }
            return obj;
        }] mutableCopy];
        if(didUpdateAnything){
            [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StackCachedPagesDidUpdateNotification" object:nil userInfo:@{ @"stackUUID" : stackUUID }];
        }
    }];
}

-(void) updateName:(NSString*)name forStack:(NSString*)stackUUID{
    [NSThread performBlockOnMainThread:^{
        __block BOOL didUpdateAnything = NO;
        stackIDs = [[stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            if([obj[@"uuid"] isEqualToString:stackUUID]){
                if(![obj[@"name"] isEqualToString:name]){
                    didUpdateAnything = YES;
                    NSMutableDictionary* mutObj = [obj mutableCopy];
                    mutObj[@"name"] = name;
                    return mutObj;
                }
            }
            return obj;
        }] mutableCopy];
        if(didUpdateAnything){
            [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StackCachedPagesDidUpdateNotification" object:nil userInfo:@{ @"stackUUID" : stackUUID }];
        }
    }];
}

#pragma mark - Upgrade to 2.0.0

-(void) checkForUpgrade{
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* visiblePagesPlist = [[documentsPath stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
    NSString* hiddenPagesPlist = [[documentsPath stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
    NSString* pagesDir = [documentsPath stringByAppendingPathComponent:@"Pages"];

    if([[NSFileManager defaultManager] fileExistsAtPath:visiblePagesPlist] &&
       [[NSFileManager defaultManager] fileExistsAtPath:hiddenPagesPlist] &&
       [[NSFileManager defaultManager] fileExistsAtPath:pagesDir]){
        stackIDs = stackIDs ?: [NSMutableArray array];
        NSString* stackID = [self createStack];

        NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:stackID];

        [[NSFileManager defaultManager] moveItemAtPath:visiblePagesPlist toPath:[stackDirectory stringByAppendingPathComponent:[visiblePagesPlist lastPathComponent]] error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:hiddenPagesPlist toPath:[stackDirectory stringByAppendingPathComponent:[hiddenPagesPlist lastPathComponent]] error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:pagesDir toPath:[stackDirectory stringByAppendingPathComponent:[pagesDir lastPathComponent]] error:nil];
    }
}

@end
