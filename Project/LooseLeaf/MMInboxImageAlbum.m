//
//  MMInboxImageAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxImageAlbum.h"
#import "MMInboxImage.h"
#import "Constants.h"


@implementation MMInboxImageAlbum {
    MMInboxImage* cachedImageAsset;
}

- (id)initWithInboxItem:(MMInboxItem*)_inboxItem {
    if (self = [super initWithInboxItem:_inboxItem]) {
        // noop
    }
    return self;
}

- (short)numberOfPreviewPhotos {
    return cachedImageAsset ? 1 : 0;
}

- (NSArray*)previewPhotos {
    return cachedImageAsset ? @[cachedImageAsset] : @[];
}

- (void)loadPreviewPhotos {
    cachedImageAsset = [[MMInboxImage alloc] initWithImageItem:self.inboxItem];
}

- (void)unloadPreviewPhotos {
    cachedImageAsset = nil;
}

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock {
    BOOL stop;
    enumerationBlock(cachedImageAsset, 0, &stop);
}

@end
