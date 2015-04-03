//
//  MMPhotoAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPhotoAlbum.h"
#import "MMPhotoManager.h"
#import "ALAsset+Thumbnail.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"
#import "NSArray+Extras.h"
#import "NSIndexSet+Map.h"

dispatch_queue_t fetchThumbnailQueue;

@implementation MMPhotoAlbum{
    ALAssetsGroup* group; // required strong ref so we get updates from asset manager
    NSURL* assetURL;
    NSString* name;
    NSString* persistentId;
    ALAssetsGroupType type;
    NSInteger numberOfPhotos;
    NSArray* previewPhotos;
    BOOL previewPhotosAreLoaded;
    BOOL reversed;
    short numberOfPreviewPhotos;
}

@synthesize assetURL;
@synthesize name;
@synthesize persistentId;
@synthesize type;
@synthesize numberOfPhotos;
@synthesize reversed;
@synthesize numberOfPreviewPhotos;

+(dispatch_queue_t) fetchThumbnailQueue{
    if(!fetchThumbnailQueue){
        fetchThumbnailQueue = dispatch_queue_create("com.milestonemade.looseleaf.fetchThumbnailQueue", DISPATCH_QUEUE_SERIAL);
    }
    return fetchThumbnailQueue;
}

-(id) initWithAssetGroup:(ALAssetsGroup *)_group{
    if(self = [super init]){
        group = _group;
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        assetURL = group.url;
        name = group.name;
        persistentId = group.persistentId;
        type = group.type;
        numberOfPhotos = group.numberOfAssets;
        previewPhotosAreLoaded = NO;
        numberOfPreviewPhotos = 5;
    }
    return self;
}

-(NSArray*) previewPhotos{
    @synchronized(self){
        return [NSArray arrayWithArray:previewPhotos];
    }
}

// refreshes preview photos as well as
// the full contents if the full contents
// are in cache
-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group{
    @synchronized(self){
        group = _group;
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        name = group.name;
        numberOfPhotos = group.numberOfAssets;
        if(previewPhotosAreLoaded){
            // we have photos loaded, but need to refresh them
            [self loadPreviewPhotos:YES];
        }
    }
}


-(void) unloadPreviewPhotos{
    @synchronized(self){
        previewPhotosAreLoaded = NO;
        previewPhotos = [NSArray array];
    }
}

-(void) loadPreviewPhotos{
    @synchronized(self){
        previewPhotosAreLoaded = YES;
        if(![previewPhotos count]){
            [self loadPreviewPhotos:NO];
        }
    }
}

BOOL isEnumerating = NO;
-(void) loadPreviewPhotos:(BOOL)force{
    if(![previewPhotos count] || force){
        NSMutableArray* updatedPreviewPhotos = [NSMutableArray array];
        @synchronized(self){
            isEnumerating = YES;
            [group enumerateAssetsWithOptions:reversed ? NULL : NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger indexOnDisk, BOOL *stop) {
                if(result){
                    [updatedPreviewPhotos addObject:[[MMPhoto alloc] initWithALAsset:result]];
                    [[updatedPreviewPhotos lastObject] aspectRatioThumbnail]; // force the thumbnail to load.
                    if([updatedPreviewPhotos count] >= numberOfPreviewPhotos){
                        stop[0] = YES;
                    }
                }else{
                    @synchronized(self){
                        previewPhotos = updatedPreviewPhotos;
                        isEnumerating = NO;
                    }
                }
            }];
        }
    }
}


-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSetInView usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock{
    @try{
        try{
            NSIndexSet* indexSetOnDisk = indexSetInView;
            if(reversed){
                // reverse what we fetch from the real album ordering
                indexSetOnDisk = [indexSetInView mapIndexesUsingBlock:^NSUInteger(NSUInteger idx) {
                    return self.numberOfPhotos - idx - 1;
                }];
            }
            ALAssetsGroupEnumerationResultsBlock indexManagerBlock = ^(ALAsset *result, NSUInteger indexOnDisk, BOOL *stop){
                // remap the index to what the user asked for.
                // this way the user's index values map to
                // new values here
                NSUInteger indexInView = reversed ? (self.numberOfPhotos - indexOnDisk - 1) : indexOnDisk;
                NSUInteger idxInPreviews = !reversed ? (self.numberOfPhotos - indexOnDisk - 1) : indexOnDisk;
                if(idxInPreviews < [previewPhotos count]){
                    enumerationBlock(result ? [previewPhotos objectAtIndex:idxInPreviews] : nil, indexInView, stop);
                }else{
                    enumerationBlock(result ? [[MMPhoto alloc] initWithALAsset:result] : nil, indexInView, stop);
                }
            };
            @synchronized(self){
//                NSInteger count = group.numberOfAssets;
                
                __block BOOL stop = NO;
                NSMutableIndexSet* indexesToLoad = [NSMutableIndexSet indexSet];
                [indexSetOnDisk enumerateIndexesUsingBlock:^(NSUInteger indexOnDisk, BOOL *_s) {
                    NSUInteger idxInView = reversed ? (self.numberOfPhotos - indexOnDisk - 1) : indexOnDisk;
                    NSUInteger idxInPreviews = !reversed ? (self.numberOfPhotos - indexOnDisk - 1) : indexOnDisk;
                    if(idxInPreviews < [previewPhotos count]){
                        enumerationBlock([previewPhotos objectAtIndex:idxInPreviews], idxInView, &stop);
                        if(stop){
                            _s[0] = YES;
                        }
                    }else{
                        [indexesToLoad addIndex:indexOnDisk];
                    }
                }];
                
                if(!stop && indexesToLoad){
                    [group enumerateAssetsAtIndexes:indexesToLoad options:NSEnumerationReverse usingBlock:indexManagerBlock];
                }
            }
        }catch(...){
            DebugLog(@"caught++");
        }
    }@catch(NSException* exception){
        if([exception.name isEqualToString:NSRangeException]){
            DebugLog(@"caught: %@ %@", exception.name, exception);
            // noop
            //
            // the album is likely changing, and will update
            // in the background soon.
            // https://github.com/adamwulf/loose-leaf/issues/529
            enumerationBlock(nil, 0, nil);
        }else{
            DebugLog(@"uncaught: %@ %@", exception.name, exception);
            @throw exception;
        }
    }@catch(...){
        DebugLog(@"caught unkown");
    }
}

-(void) dealloc{
    @synchronized(self){
        if(isEnumerating){
            DebugLog(@"what: dealloc during enumeration");
        }
    }
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMPhotoAlbum(%p): %@ %@]", self, self.name, self.persistentId];
}

@end
