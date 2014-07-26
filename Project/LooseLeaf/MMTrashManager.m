//
//  MMTrashManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashManager.h"

@implementation MMTrashManager

#pragma mark - Singleton

static MMTrashManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
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
    NSLog(@"deleting scrap %@ in page %@", scrapUUID, pageUUID);

}

@end
