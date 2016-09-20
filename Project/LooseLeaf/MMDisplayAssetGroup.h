//
//  MMDisplayAssetGroup.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/5/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDisplayAsset.h"

typedef void (^MMDisplayAssetGroupEnumerationResultsBlock)(MMDisplayAsset* result, NSUInteger index, BOOL* stop);


@interface MMDisplayAssetGroup : NSObject

@property (readonly) NSURL* assetURL;
@property (readonly) NSString* name;
@property (readonly) NSString* persistentId;
@property (readonly) NSInteger numberOfPhotos;
@property (readonly) NSArray* previewPhotos;
@property (assign) BOOL reversed;
@property (assign) short numberOfPreviewPhotos;

- (void)loadPreviewPhotos;

- (void)unloadPreviewPhotos;

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock;

@end
