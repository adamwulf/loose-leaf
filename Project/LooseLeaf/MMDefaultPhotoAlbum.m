//
//  MMDefaultPhotoAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDefaultPhotoAlbum.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSArray+IndexSetAdditions.h"
#import "NSArray+Map.h"

@implementation MMDefaultPhotoAlbum{
    NSString* directoryPath;
}

-(id) initWithPhotosInDirectory:(NSString*)_directoryPath{
    if(self = [super init]){
        directoryPath = _directoryPath;
    }
    return self;
}

-(void) loadPreviewPhotos{
    // noop
}

-(void) refreshAlbumContentsWithGroup:(ALAssetsGroup*)_group{
    // noop
}

-(void) unloadPreviewPhotos{
    // noop
}

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMPhotoGroupEnumerationResultsBlock)enumerationBlock{
    NSArray* arr = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:directoryPath filesOnly:YES];
    arr = [arr subarrayWithIndexes:indexSet];
    
    NSMutableArray* allIndexes = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [allIndexes addObject:@(idx)];
    }];
    
    __block BOOL stop = NO;
    [arr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        if(!stop){
            NSUInteger indexOfPhoto = [[allIndexes objectAtIndex:idx] unsignedIntegerValue];
            enumerationBlock([[MMPhoto alloc] init], indexOfPhoto, &stop);
        }
        return obj;
    }];
}


@end
