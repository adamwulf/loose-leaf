//
//  MMPDFAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbum.h"
#import "MMPDF.h"

@interface MMPDFAlbum : MMPhotoAlbum

@property (readonly) NSURL* assetURL;
@property (readonly) NSString* name;
@property (readonly) NSString* persistentId;
@property (readonly) ALAssetsGroupType type;
@property (readonly) NSInteger numberOfPhotos;
@property (readonly) NSArray* previewPhotos;
@property (assign) BOOL reversed;
@property (assign) short numberOfPreviewPhotos;

-(id) initWithAssetGroup:(ALAssetsGroup*)group NS_UNAVAILABLE;

-(id) initWithPDF:(MMPDF*)pdf;

-(void) loadPreviewPhotos;

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group;

-(void) unloadPreviewPhotos;

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMPhotoGroupEnumerationResultsBlock)enumerationBlock;

@end
