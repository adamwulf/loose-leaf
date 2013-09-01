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

-(void) didTapToAddScrapBackToPage:(MMScrapView*)scrap;

@end
