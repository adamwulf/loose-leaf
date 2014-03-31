//
//  MMPhotoManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMPhotoManagerDelegate.h"
#import "MMPhotoAlbum.h"
#import "MMPhotoAlbumDelegate.h"

#define kPermissionDeniedError 401

@interface MMPhotoManager : NSObject<MMPhotoAlbumDelegate>{
    __weak NSObject<MMPhotoManagerDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMPhotoManagerDelegate>* delegate;
@property (readonly) NSUInteger countOfAlbums;
@property (readonly) NSArray* albums;
@property (readonly) NSArray* events;
@property (readonly) NSArray* faces;
@property (readonly) MMPhotoAlbum* cameraRoll;
@property (readonly) ALAssetsLibrary* assetsLibrary;

+(MMPhotoManager*) sharedInstace;

-(void) initializeAlbumCache:(NSError**)err;

@end
