//
//  MMPhotoAlbumDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMPhotoAlbum;

@protocol MMPhotoAlbumDelegate <NSObject>

-(void) loadedPreviewPhotosFor:(MMPhotoAlbum*)album;

@end
