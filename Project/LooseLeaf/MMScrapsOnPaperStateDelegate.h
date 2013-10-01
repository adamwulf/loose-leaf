//
//  MMScrapsOnPaperStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapView;

@protocol MMScrapsOnPaperStateDelegate <NSObject>

-(NSArray*) scraps;

-(void) didLoadScrap:(MMScrapView*)scrap;

@end
