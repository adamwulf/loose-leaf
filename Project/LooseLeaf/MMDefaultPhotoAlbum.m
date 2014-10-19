//
//  MMDefaultPhotoAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDefaultPhotoAlbum.h"
#import "MMPhotoOnDisk.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSArray+IndexSetAdditions.h"
#import "NSArray+Map.h"

@implementation MMDefaultPhotoAlbum{
    NSString* directoryPath;
    NSArray* photos;
    NSArray* previewPhotos;
}

-(NSURL*) assetURL{
    return [[NSURL alloc] initFileURLWithPath:directoryPath];
}
-(NSString*) name{
    return [directoryPath lastPathComponent];
}
-(NSString*) persistentId{
    return directoryPath;
}
-(ALAssetsGroupType) type{
    return ALAssetsGroupAlbum;
}
-(NSInteger)numberOfPhotos{
    return [photos count];
}
-(NSArray*) previewPhotos{
    return previewPhotos;
}


-(id) initWithPhotosInDirectory:(NSString*)_directoryPath{
    if(self = [super init]){
        directoryPath = _directoryPath;
        photos = [[[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:directoryPath filesOnly:YES] mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [[MMPhotoOnDisk alloc] initWithPath:[directoryPath stringByAppendingPathComponent:obj]];
        }];
    }
    return self;
}

-(void) loadPreviewPhotos{
    previewPhotos = [photos subarrayWithRange:NSMakeRange(0, MIN(5, self.numberOfPhotos))];
}

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group{
    // noop
}

-(void) unloadPreviewPhotos{
    // noop
}

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMPhotoGroupEnumerationResultsBlock)enumerationBlock{
    NSArray* arr = [photos subarrayWithIndexes:indexSet];
    
    NSMutableArray* allIndexes = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [allIndexes addObject:@(idx)];
    }];
    
    __block BOOL stop = NO;
    [arr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        if(!stop){
            NSUInteger indexOfPhoto = [[allIndexes objectAtIndex:idx] unsignedIntegerValue];
            enumerationBlock(obj, indexOfPhoto, &stop);
        }
        return obj;
    }];
}

@end
