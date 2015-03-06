//
//  MMPDFAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFAlbum.h"
#import "NSString+UUID.h"
#import "MMPDFPage.h"

@implementation MMPDFAlbum{
    MMPDF* pdf;
    NSArray* previewPhotos;
    NSMutableDictionary* cachedPages;
}

@synthesize pdf;

-(id) initWithPDF:(MMPDF *)_pdf{
    if(self = [super init]){
        pdf = _pdf;
        [self loadPreviewPhotos];
        cachedPages = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSURL*) assetURL{
    return [pdf urlOnDisk];
}

-(NSString*) name{
    return [[pdf urlOnDisk] lastPathComponent];
}

-(NSString*) persistentId{
    return [[pdf urlOnDisk] path];
}

-(NSInteger) numberOfPhotos{
    return [pdf pageCount];
}

-(NSArray*) previewPhotos{
    return previewPhotos;
}

-(BOOL) reversed{
    return NO;
}

-(short) numberOfPreviewPhotos{
    return [previewPhotos count];
}

-(void) loadPreviewPhotos{
    previewPhotos = @[];
    for (int i=0; i<5 && i < [pdf pageCount]; i++) {
        previewPhotos = [previewPhotos arrayByAddingObject:[[MMPDFPage alloc] initWithPDF:pdf andPage:i]];
        [cachedPages setObject:[previewPhotos lastObject] forKey:@(i)];
    }
}

-(void) unloadPreviewPhotos{
    previewPhotos = @[];
    [cachedPages removeAllObjects];
}

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock{
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MMPDFPage* page = [cachedPages objectForKey:@(idx)];
        if(!page){
            page = [[MMPDFPage alloc] initWithPDF:pdf andPage:idx];
            [cachedPages setObject:page forKey:@(idx)];
        }
        enumerationBlock(page, idx, stop);
    }];
}

@end
