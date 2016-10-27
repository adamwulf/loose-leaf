//
//  MMPDFAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFAssetGroup.h"
#import "NSString+UUID.h"
#import "MMPDFPageAsset.h"


@implementation MMPDFAssetGroup {
    NSArray* previewPhotos;
    NSMutableDictionary* cachedPages;
}

- (id)initWithInboxItem:(MMPDFInboxItem*)_pdf {
    if (self = [super initWithInboxItem:_pdf]) {
        [self loadPreviewPhotos];
        cachedPages = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray*)previewPhotos {
    return previewPhotos;
}

- (BOOL)reversed {
    return NO;
}

- (short)numberOfPreviewPhotos {
    return [previewPhotos count];
}

- (MMPDFPageAsset*)pdfPageForIndex:(NSInteger)idx {
    MMPDFPageAsset* page = [cachedPages objectForKey:@(idx)];
    if (!page) {
        page = [[MMPDFPageAsset alloc] initWithPDF:(MMPDFInboxItem*)self.inboxItem andPage:idx];
        [cachedPages setObject:page forKey:@(idx)];
    }
    return page;
}

- (void)loadPreviewPhotos {
    previewPhotos = @[];
    for (int idx = 0; idx < 5 && idx < [self.inboxItem pageCount]; idx++) {
        MMPDFPageAsset* page = [self pdfPageForIndex:idx];
        previewPhotos = [previewPhotos arrayByAddingObject:page];
    }
}

- (void)unloadPreviewPhotos {
    previewPhotos = @[];
    [cachedPages removeAllObjects];
}

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
        MMPDFPageAsset* page = [self pdfPageForIndex:idx];
        enumerationBlock(page, idx, stop);
    }];
}

@end
