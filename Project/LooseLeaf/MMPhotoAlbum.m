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

-(id) initWithAssetGroup:(ALAssetsGroup *)group{
    if(self = [super init]){
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

-(void) loadPreviewPhotos{
    if(![previewPhotos count]){
        NSMutableArray* updatedPreviewPhotos = [NSMutableArray array];
        [[[MMPhotoManager sharedInstace] assetsLibrary] groupForURL:assetURL resultBlock:^(ALAssetsGroup* group){
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
                    [delegate loadedPreviewPhotos];
                }
            }];
        } failureBlock:^(NSError* err){
            NSLog(@"can't get images");
        }];
    }else{
        [delegate loadedPreviewPhotos];
    }
}


@end
