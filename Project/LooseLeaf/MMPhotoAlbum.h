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
#import "MMPhotoAlbumDelegate.h"

@interface MMPhotoAlbum : NSObject{
    __weak NSObject<MMPhotoAlbumDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMPhotoAlbumDelegate>* delegate;
@property (readonly) NSURL* assetURL;
@property (readonly) NSString* name;
@property (readonly) NSString* persistentId;
@property (readonly) ALAssetsGroupType type;
@property (readonly) NSInteger numberOfPhotos;
@property (readonly) NSArray* previewPhotos;

-(id) initWithAssetGroup:(ALAssetsGroup*)group;

-(void) loadPreviewPhotos;

-(void) refreshAlbumContents;

@end
