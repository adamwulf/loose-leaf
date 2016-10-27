//
//  MMDisplayAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/5/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"
#import "Constants.h"


@implementation MMDisplayAssetGroup

- (void)loadPreviewPhotos {
    @throw kAbstractMethodException;
}

- (void)unloadPreviewPhotos {
    @throw kAbstractMethodException;
}

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock {
    @throw kAbstractMethodException;
}

@end
