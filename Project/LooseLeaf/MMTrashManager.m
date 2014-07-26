//
//  MMTrashManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashManager.h"
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMTrashManager{
    dispatch_queue_t trashManagerQueue;
    NSFileManager* fileManager;
}

#pragma mark - Dispatch Queue

-(dispatch_queue_t) trashManagerQueue{
    if(!trashManagerQueue){
        trashManagerQueue = dispatch_queue_create("com.milestonemade.looseleaf.trashManagerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return trashManagerQueue;
}

#pragma mark - Singleton

static MMTrashManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        fileManager = [[NSFileManager alloc] init];
    }
    return _instance;
}

+(MMTrashManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMTrashManager alloc]init];
    }
    return _instance;
}


#pragma mark - Delete Methods

-(void) deleteScrap:(NSString*)scrapUUID inPage:(NSString*)pageUUID{
    //
    dispatch_async([self trashManagerQueue], ^{
        NSLog(@"deleting scrap %@ in page %@", scrapUUID, pageUUID);
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* pagesPath = [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:pageUUID];
        NSString* scrapPath = [[pagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:scrapUUID];
        
        BOOL isDirectory = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:scrapPath isDirectory:&isDirectory]){
            if(isDirectory){
                NSLog(@"found path to delete %@", scrapPath);
                NSError* err = nil;
                if([[NSFileManager defaultManager] removeItemAtPath:scrapPath error:&err]){
                    NSLog(@"deleted %@", scrapPath);
                }
                if(err){
                    NSLog(@"error deleting %@: %@", scrapPath, err);
                }
            }else{
                NSLog(@"found path, but it isn't a directory");
            }
        }else{
            NSLog(@"path to delete doesn't exist %@", scrapPath);
        }
    });
}

@end
