//
//  MMInboxImageAlbum.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxImageAlbum.h"
#import "Constants.h"

@implementation MMInboxImageAlbum{
    NSURL* imageURL;
}

-(id) initWithImageAtURL:(NSURL*)_imageURL{
    if(self = [super init]){
        imageURL = _imageURL;
    }
    return self;
}

-(void) loadPreviewPhotos{
    @throw kAbstractMethodException;
}

-(void) unloadPreviewPhotos{
    @throw kAbstractMethodException;
}

-(void) loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock{
    @throw kAbstractMethodException;
}

@end
