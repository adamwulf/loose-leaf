//
//  MMScrapState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapStateDelegate.h"

@class MMImmutableScrapState;

@interface MMScrapState : NSObject{
    __weak NSObject<MMScrapStateDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMScrapStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;


-(id) initWithScrapIDsPath:(NSString*)scrapIDsPath;

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async;

-(void) unload;

-(MMImmutableScrapState*) immutableState;

@end
