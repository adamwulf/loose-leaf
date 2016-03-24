//
//  MMStacksManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStacksManager.h"
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMStacksManager{
    NSMutableArray* stackIDs;
}

static MMStacksManager* _instance = nil;

+(void)load{
    [MMStacksManager sharedInstance];
}

+(MMStacksManager*) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMStacksManager alloc]init];
    });
    return _instance;
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
    return [stackIDs copy];
}

-(NSString*) createStack{
    NSString* uuid = [[NSUUID UUID] UUIDString];

    NSError* err;
    NSString* stackDirectory = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"Stacks"] stringByAppendingPathComponent:uuid];
    [[NSFileManager defaultManager] createDirectoryAtPath:stackDirectory withIntermediateDirectories:YES attributes:nil error:&err];

    [stackIDs addObject:uuid];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];

    return uuid;
}

-(void) deleteStack:(NSString*)stackUUID{
    [stackIDs removeObject:stackUUID];
    [[NSKeyedArchiver archivedDataWithRootObject:stackIDs] writeToFile:[[NSFileManager documentsPath] stringByAppendingPathComponent:@"stacks.plist"] atomically:YES];    
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
