//
//  MMTrashManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"
#import "MMScrappedPaperView.h"

@interface MMTrashManager : NSObject

+(MMTrashManager*) sharedInstance;

-(dispatch_queue_t) trashManagerQueue;

+(BOOL) isTrashManagerQueue;

-(void) deleteScrap:(NSString*)scrap inScrapCollectionState:(MMScrapCollectionState*)scrapCollectionState;

-(void) deletePage:(MMPaperView*)page;

@end
