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
    }
    return _instance;
}

+(SLBackingStoreManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLBackingStoreManager alloc] init];
    }
    return _instance;
}





@end
