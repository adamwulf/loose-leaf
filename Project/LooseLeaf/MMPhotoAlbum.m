//
//  MMPhotoAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbum.h"
#import "MMPhotoManager.h"

@implementation MMPhotoAlbum{
    ALAssetsGroup* group; // required strong ref so we get updates from asset manager
    NSURL* assetURL;
    NSString* name;
    NSString* persistentId;
    ALAssetsGroupType type;
    NSInteger numberOfPhotos;
    UIImage* poster;
    NSArray* previewPhotos;
}

@synthesize delegate;
@synthesize assetURL;
@synthesize name;
@synthesize persistentId;
@synthesize type;
@synthesize numberOfPhotos;

-(id) initWithAssetGroup:(ALAssetsGroup *)_group{
    if(self = [super init]){
        group = _group;
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        assetURL = group.url;
        name = group.name;
        persistentId = group.persistentId;
        type = group.type;
        numberOfPhotos = group.numberOfAssets;
        poster = [UIImage imageWithCGImage:group.posterImage];
    }
    return self;
}

-(NSArray*) previewPhotos{
    return [NSArray arrayWithArray:previewPhotos];
}

// refreshes preview photos as well as
// the full contents if the full contents
// are in cache
-(void) refreshAlbumContents{
    [self loadPreviewPhotos:YES];
}

-(void) loadPreviewPhotos{
    [self loadPreviewPhotos:NO];
}

-(void) loadPreviewPhotos:(BOOL)force{
    if(![previewPhotos count] || force){
        NSMutableArray* updatedPreviewPhotos = [NSMutableArray array];
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                [updatedPreviewPhotos addObject:[UIImage imageWithCGImage:result.thumbnail]];
                if([updatedPreviewPhotos count] >= 5){
                    stop[0] = YES;
                    previewPhotos = updatedPreviewPhotos;
                    [delegate loadedPreviewPhotos];
                }
            }else{
                previewPhotos = updatedPreviewPhotos;
                [delegate performSelectorOnMainThread:@selector(loadedPreviewPhotos) withObject:nil waitUntilDone:NO];
            }
        }];
    }else{
        [delegate performSelectorOnMainThread:@selector(loadedPreviewPhotos) withObject:nil waitUntilDone:NO];
    }
}


@end
