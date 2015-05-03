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
#import "MMDisplayAssetGroup.h"

@interface MMPhotoAlbum : MMDisplayAssetGroup

@property (readonly) ALAssetsGroupType type;

-(id) initWithAssetGroup:(ALAssetsGroup*)group;

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group;

@end
