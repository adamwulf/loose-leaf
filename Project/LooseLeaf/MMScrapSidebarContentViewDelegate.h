//
//  MMScrapBezelMenuViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"
#import "MMSlidingSidebarContentViewDelegate.h"

@protocol MMScrapSidebarContentViewDelegate <MMSlidingSidebarContentViewDelegate>

-(NSArray*) scraps;

-(void) didTapOnScrapFromMenu:(MMScrapView*)scrap;

@end
