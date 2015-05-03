//
//  MMImageImporter.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMInboxManagerDelegate.h"

@interface MMInboxManager : NSObject

@property (nonatomic, weak) NSObject<MMInboxManagerDelegate>* delegate;

+(MMInboxManager*) sharedInstance;

-(void) processInboxItem:(NSURL*)itemURL fromApp:(NSString*)sourceApplication;

- (void)removeInboxItem:(NSURL *)itemURL onComplete:(void(^)(BOOL error))onComplete;

-(NSInteger) itemsInInboxCount;

-(MMInboxItem*) itemAtIndex:(NSInteger)idx;

-(NSInteger) indexOfItem:(MMInboxItem*)item;

@end
