//
//  SLBackingStoreManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import "SLBackingStoreManager.h"

@implementation SLBackingStoreManager

@synthesize delegate;
@synthesize opQueue;

static SLBackingStoreManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
        opQueue.name = @"SLBackingStoreManager Queue";
        setOfPointers = [[NSMutableSet alloc] init];
    }
    return _instance;
}

+(SLBackingStoreManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLBackingStoreManager alloc] init];
    }
    return _instance;
}


-(void*) getZerodPointerForMemory:(int) size{
    void* ret = [self getPointerForMemory:size];
    memset(ret, 0, size);
    return ret;
}

-(void*) getPointerForMemory:(int) size{
    @synchronized(self){
        NSValue* obj = [setOfPointers anyObject];
        void* ret = nil;
        if(obj){
            ret = [obj pointerValue];
            [setOfPointers removeObject:obj];
        }else{
            ret = calloc(1, size);
        }
        return ret;
    }
}

-(void) givePointerForMemory:(void*)ptr{
    @synchronized(self){
        if([setOfPointers count] >= 1){
            free(ptr);
        }else{
            [setOfPointers addObject:[NSValue valueWithPointer:ptr]];
        }
    }
}

-(void) didReceiveMemoryWarning{
    @synchronized(self){
        NSLog(@"did get memory warning: %d", [setOfPointers count]);
        while([setOfPointers count]){
            NSValue* val = [setOfPointers anyObject];
            void* ptr = [val pointerValue];
            free (ptr);
            [setOfPointers removeObject:val];
        }
    }
}


@end
