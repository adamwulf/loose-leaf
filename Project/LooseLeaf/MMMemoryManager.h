//
//  MMMemoryManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapPaperStackView.h"

@interface MMMemoryManager : NSObject

@property (readonly) int virtualSize;
@property (readonly) int residentSize;
@property (readonly) int residentPageStateMemory;
@property (readonly) int residentStackViewMemory;
@property (readonly) int residentTrashMemory;
@property (readonly) int residentImageCacheMemory;
@property (readonly) int accountedResidentBytes;
@property (readonly) int unaccountedResidentBytes;
@property (readonly) int numberInImageCache;
@property (readonly) int numberOfLoadedPagePreviews;
@property (readonly) int numberOfLoadedPageStates;
@property (readonly) int numberOfItemsInTrash;
@property (readonly) int totalBytesInScrapBackgrounds;
@property (readonly) int totalBytesInVBOs;
@property (readonly) int totalBytesInTextures;

-(id) initWithStack:(MMScrapPaperStackView*)stack;

@end
