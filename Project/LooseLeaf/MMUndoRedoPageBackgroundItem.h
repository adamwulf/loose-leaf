//
//  MMUndoRedoPageBackgroundItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageItem.h"
#import "MMBackgroundedPaperView.h"

@interface MMUndoRedoPageBackgroundItem : MMUndoRedoPageItem

@property (nonatomic, readonly) MMBackgroundedPaperView* page;

+ (id)itemForPage:(MMBackgroundedPaperView*)page andOriginalBackground:(NSDictionary*)originalProps andUpdatedBackground:(NSDictionary*)updatedProps;

- (id)initForPage:(MMBackgroundedPaperView*)page andOriginalBackground:(NSDictionary*)originalProps andUpdatedBackground:(NSDictionary*)updatedProps;

@end
