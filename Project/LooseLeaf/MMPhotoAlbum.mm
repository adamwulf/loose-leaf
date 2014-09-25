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
}

@synthesize assetURL;
@synthesize name;
@synthesize persistentId;
@synthesize type;
@synthesize numberOfPhotos;
@synthesize reversed;

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
            [group enumerateAssetsWithOptions:reversed ? NULL : NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result){
                    [updatedPreviewPhotos addObject:[UIImage imageWithCGImage:result.aspectRatioThumbnail]];
                    if([updatedPreviewPhotos count] >= 5){
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


-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(ALAssetsGroupEnumerationResultsBlock)enumerationBlock{
    @try{
        try{
            if(reversed){
                // reverse what we fetch from the real album ordering
                indexSet = [indexSet mapIndexesUsingBlock:^NSUInteger(NSUInteger idx) {
                    return self.numberOfPhotos - idx - 1;
                }];
            }
            ALAssetsGroupEnumerationResultsBlock indexManagerBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if(reversed){
                    // remap the index to what the user asked for.
                    // this way the user's index values map to
                    // new values here
                    index = self.numberOfPhotos - index - 1;
                }
                enumerationBlock(result, index, stop);
            };
            @synchronized(self){
                [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:indexManagerBlock];
            }
        }catch(...){
            NSLog(@"caught++");
        }
    }@catch(NSException* exception){
        if([exception.name isEqualToString:NSRangeException]){
            NSLog(@"caught: %@ %@", exception.name, exception);
            // noop
            //
            // the album is likely changing, and will update
            // in the background soon.
            // https://github.com/adamwulf/loose-leaf/issues/529
            enumerationBlock(nil, 0, nil);
        }else{
            NSLog(@"uncaught: %@ %@", exception.name, exception);
            @throw exception;
        }
    }@catch(...){
        NSLog(@"caught unkown");
    }
}

-(void) dealloc{
    @synchronized(self){
        if(isEnumerating){
            debug_NSLog(@"what: dealloc during enumeration");
        }
    }
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[MMPhotoAlbum(%p): %@ %@]", self, self.name, self.persistentId];
}

@end
