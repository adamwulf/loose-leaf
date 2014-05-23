//
//  MMInboxManagerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMInboxManagerDelegate <NSObject>

-(void) didProcessIncomingImage:(UIImage*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication;

-(void) failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication;

@end
