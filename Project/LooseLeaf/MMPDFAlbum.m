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
}

-(id) initWithPDF:(MMPDF *)_pdf{
    if(self = [super init]){
        pdf = _pdf;
        [self loadPreviewPhotos];
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

-(ALAssetsGroupType) type{
    return ALAuthorizationStatusAuthorized;
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
    }
}

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group{
    @throw [NSException exceptionWithName:@"PDFException" reason:@"nope" userInfo:nil];
}

-(void) unloadPreviewPhotos{
//    previewPhotos = nil;
}

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMPhotoGroupEnumerationResultsBlock)enumerationBlock{
    // todo
}

@end
