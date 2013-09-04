//
//  MMScapBubbleContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"

@protocol MMScapBubbleContainerViewDelegate <NSObject>

-(void) didAddScrapToBezelSidebar:(MMScrapView*)scrap;

-(void) didAddScrapBackToPage:(MMScrapView*)scrap;

-(CGPoint) positionOnScreenToScaleScrapTo:(MMScrapView*)scrap;

-(CGFloat) scaleOnScreenToScaleScrapTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale;

@end
