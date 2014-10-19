//
//  MMScrappedPaperViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapView;

@protocol MMScrapViewOwnershipDelegate <NSObject>

-(MMScrapView*) scrapForUUIDIfAlreadyExistsInOtherContainer:(NSString*)scrapUUID;

@end
