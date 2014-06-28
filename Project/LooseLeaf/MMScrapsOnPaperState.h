//
//  MMScrapsOnPaperState.h
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
    BOOL shouldShowShadows;
}

@property (nonatomic, weak) NSObject<MMScrapsOnPaperStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;
@property (nonatomic, assign) BOOL shouldShowShadows;
@property (nonatomic, readonly) int fullByteSize;

+(dispatch_queue_t) importExportStateQueue;

-(id) init;

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable;

-(void) unload;

-(MMImmutableScrapsOnPaperState*) immutableStateForPath:(NSString*)scrapIDsPath;

@end
