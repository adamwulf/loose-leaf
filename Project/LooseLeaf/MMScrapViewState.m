//
//  MMScrapViewState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapViewState.h"

@implementation MMScrapViewState{
    NSString* uuid;
    // the path where we store our data
    NSString* scrapPath;
}

-(id) initWithUUID:(NSString*)_uuid{
    if(self = [super init]){
        uuid = _uuid;
    }
    return self;
}

@end
