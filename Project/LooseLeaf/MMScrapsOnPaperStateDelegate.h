//
//  MMScrapsOnPaperStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapView, MMScrapsOnPaperState;

@protocol MMScrapsOnPaperStateDelegate <NSObject>

-(NSArray*) scrapsOnPaper;

-(void) didLoadScrap:(MMScrapView*)scrap;

-(void) didLoadAllScrapsFor:(MMScrapsOnPaperState*)scrapState;

-(void) didUnloadAllScrapsFor:(MMScrapsOnPaperState*)scrapState;

@end
