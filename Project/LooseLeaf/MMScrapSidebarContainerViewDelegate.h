//
//  MMScrapSidebarViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"
#import "MMUndoablePaperView.h"
#import "MMCountableSidebarContainerViewDelegate.h"

@protocol MMScrapSidebarContainerViewDelegate <MMCountableSidebarContainerViewDelegate>

- (MMScrappedPaperView*)pageForUUID:(NSString*)uuid;

@end
