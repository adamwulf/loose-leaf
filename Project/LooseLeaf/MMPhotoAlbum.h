//
//  MMPhotoAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsGroup+Properties.h"
#import "MMPhoto.h"

typedef void (^MMPhotoGroupEnumerationResultsBlock)(MMPhoto *result, NSUInteger index, BOOL *stop);

@interface MMPhotoAlbum : NSObject

@property (readonly) NSURL* assetURL;
@property (readonly) NSString* name;
@property (readonly) NSString* persistentId;
@property (readonly) ALAssetsGroupType type;
@property (readonly) NSInteger numberOfPhotos;
@property (readonly) NSArray* previewPhotos;
@property (assign) BOOL reversed;
@property (assign) short numberOfPreviewPhotos;

-(id) initWithAssetGroup:(ALAssetsGroup*)group;

-(void) loadPreviewPhotos;

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group;

-(void) unloadPreviewPhotos;

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMPhotoGroupEnumerationResultsBlock)enumerationBlock;

@end
