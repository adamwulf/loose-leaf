//
//  MMMemoryManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapPaperStackView;

@protocol MMMemoryManagerDelegate <NSObject>

- (int)fullByteSize;

@end


@interface MMMemoryManager : NSObject

@property (nonatomic, weak) id<MMMemoryManagerDelegate> delegate;

@property (readonly) int maxVirtualSize;
@property (readonly) int maxResidentSize;
@property (readonly) int maxAccountedResidentBytes;
@property (readonly) int maxUnaccountedResidentBytes;
@property (readonly) int maxTotalBytesInScrapBackgrounds;
@property (readonly) int maxTotalBytesInVBOs;
@property (readonly) int maxTotalBytesInTextures;
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

- (id)initWithDelegate:(id<MMMemoryManagerDelegate>)delegate;

@end
