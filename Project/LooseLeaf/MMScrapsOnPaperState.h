//
//  MMScrapState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsOnPaperStateDelegate.h"

@class MMImmutableScrapsOnPaperState;

@interface MMScrapsOnPaperState : NSObject{
    __weak NSObject<MMScrapsOnPaperStateDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMScrapsOnPaperStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;


-(id) initWithScrapIDsPath:(NSString*)scrapIDsPath;

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async;

-(void) unload;

-(MMImmutableScrapsOnPaperState*) immutableState;

@end
