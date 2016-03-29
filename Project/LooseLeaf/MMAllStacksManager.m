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

#pragma mark - Thumbnails

//-(void) loadThumbsForStackUUID:(NSString*)stackUUID{
//    NSDictionary* stackPageIDs = [MMSingleStackManager loadFromDiskForStackUUID:stackUUID];
//    
//    NSArray* allPages = [stackPageIDs[@"visiblePages"] arrayByAddingObjectsFromArray:[stackPageIDs[@"hiddenPages"] reversedArray]];
//    
//    NSString* page1UUID = [allPages firstObject][@"uuid"];
//    if([self loadThumb:page1UUID intoImageView:page1Thumbnail]){
//        page1Thumbnail.transform = page1Transform;
//    }else{
//        page1Thumbnail.transform = CGAffineTransformIdentity;
//    }
//    
//    if([allPages count] > 1){
//        NSString* page2UUID = [allPages objectAtIndex:1][@"uuid"];
//        [self loadThumb:page2UUID intoImageView:page2Thumbnail];
//    }else{
//        page2Thumbnail.image = nil;
//    }
//    
//    if([allPages count] > 2){
//        NSString* page3UUID = [allPages objectAtIndex:2][@"uuid"];
//        [self loadThumb:page3UUID intoImageView:page3Thumbnail];
//    }else{
//        page3Thumbnail.image = nil;
//    }
//}
//
//-(BOOL) loadThumb:(NSString*)pageUUID intoImageView:(UIImageView*)imgView{
//    NSString* stackPath = [[MMAllStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID];
//    NSString* pagePath = [[stackPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:pageUUID];
//    NSString* thumbPath = [pagePath stringByAppendingPathComponent:@"scrapped.thumb.png"];
//    
//    if([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]){
//        UIImage* thumb = [[UIImage imageWithContentsOfFile:thumbPath] transparentBorderImage:2];
//        if(thumb){
//            NSLog(@"have thumb: %@", thumbPath);
//            imgView.image = thumb;
//        }else{
//            NSLog(@"should have thumb but don't");
//            imgView.image = whiteThumb;
//        }
//        return YES;
//    }else if([[NSFileManager defaultManager] fileExistsAtPath:pagePath]){
//        NSLog(@"page is white");
//        imgView.image = whiteThumb;
//        return YES;
//    }else{
//        NSLog(@"no pages");
//        imgView.image = missingThumb;
//    }
//    return NO;
//}

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
