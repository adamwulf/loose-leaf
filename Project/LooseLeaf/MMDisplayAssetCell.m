//
//  MMDisplayAssetCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetCell.h"
#import "MMBufferedImageView.h"
#import "Constants.h"


@implementation MMDisplayAssetCell

@synthesize delegate = _delegate;
@synthesize rotation = _rotation;

#pragma mark - Loading

- (void)loadPhotoFromAlbum:(MMDisplayAssetGroup*)album atIndex:(NSInteger)photoIndex {
    _album = album;
    _index = photoIndex;
}

@end
