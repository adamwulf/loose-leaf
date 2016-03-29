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
#import "NSArray+Map.h"

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
    return [stackIDs mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        return obj[@"uuid"];
    }];
}

-(NSString*) nameOfStack:(NSString*)stackUUID{
    return [stackIDs jotReduce:^id(id obj, NSUInteger index, id accum) {
        if([obj[@"uuid"] isEqualToString:stackUUID]){
            return obj[@"name"];
        }
        return accum;
    }];
}

-(NSString*) createStack{
    NSString* uuid = [[NSUUID UUID] UUIDString];

    NSError* err;
    NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:uuid];
    [[NSFileManager defaultManager] createDirectoryAtPath:stackDirectory withIntermediateDirectories:YES attributes:nil error:&err];

    [stackIDs addObject:@{ @"uuid" : uuid , @"name" : @"" }];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];

    return uuid;
}

-(void) deleteStack:(NSString*)stackUUID{
    [stackIDs filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject[@"uuid"] isEqualToString:stackUUID];
    }]];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSFileManager defaultManager] removeItemAtPath:[self stackDirectoryPathForUUID:stackUUID] error:nil];
    });
}

#pragma mark - Upgrade to 2.0.0

-(void) checkForUpgrade{
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* visiblePages = [[documentsPath stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
    NSString* hiddenPages = [[documentsPath stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
    NSString* pagesDir = [documentsPath stringByAppendingPathComponent:@"Pages"];

    if([[NSFileManager defaultManager] fileExistsAtPath:visiblePages] &&
       [[NSFileManager defaultManager] fileExistsAtPath:hiddenPages] &&
       [[NSFileManager defaultManager] fileExistsAtPath:pagesDir]){
        stackIDs = stackIDs ?: [NSMutableArray array];
        NSString* stackID = [self createStack];

        NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:stackID];

        [[NSFileManager defaultManager] moveItemAtPath:visiblePages toPath:[stackDirectory stringByAppendingPathComponent:[visiblePages lastPathComponent]] error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:hiddenPages toPath:[stackDirectory stringByAppendingPathComponent:[hiddenPages lastPathComponent]] error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:pagesDir toPath:[stackDirectory stringByAppendingPathComponent:[pagesDir lastPathComponent]] error:nil];
    }
}

@end
