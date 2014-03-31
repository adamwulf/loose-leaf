//
//  MMPhotoAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbum.h"
#import "MMPhotoManager.h"
#import "ALAsset+Thumbnail.h"

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
-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group{
    group = _group;
    name = group.name;
    if(shouldLoad){
        [self loadPreviewPhotos:YES];
    }
}

BOOL shouldLoad = NO;

-(void) unloadPreviewPhotos{
    shouldLoad = NO;
    previewPhotos = [NSArray array];
}

-(void) loadPreviewPhotos{
    shouldLoad = YES;
    if(![previewPhotos count]){
        [self performSelectorInBackground:@selector(loadPreviewPhotos:) withObject:nil];
    }else{
        [delegate loadedPreviewPhotosFor:self];
    }
}

-(void) loadPreviewPhotos:(BOOL)force{
    if(![previewPhotos count] || force){
        NSLog(@"running query for %@", self.name);
        NSMutableArray* updatedPreviewPhotos = [NSMutableArray array];
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                [updatedPreviewPhotos addObject:[UIImage imageWithCGImage:result.aspectRatioThumbnail]];
                if([updatedPreviewPhotos count] >= 5){
                    stop[0] = YES;
                }
            }else{
                previewPhotos = updatedPreviewPhotos;
                [delegate performSelectorOnMainThread:@selector(loadedPreviewPhotosFor:) withObject:self waitUntilDone:NO];
            }
        }];
    }else{
        [delegate performSelectorOnMainThread:@selector(loadedPreviewPhotosFor:) withObject:self waitUntilDone:NO];
    }
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMPhotoAlbum(%p): %@ %@]", self, self.name, self.persistentId];
}

@end
