//
//  SLBackingStoreManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import "SLBackingStoreManager.h"

@implementation SLBackingStoreManager

static SLBackingStoreManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        
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
