//
//  MMAlbumRowView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMAlbumRowViewDelegate.h"
#import "MMPhotoAlbum.h"


@interface MMAlbumRowView : UIView {
    __weak NSObject<MMAlbumRowViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMAlbumRowViewDelegate>* delegate;
@property (nonatomic, strong) MMPhotoAlbum* album;
@property (readonly) NSArray* bufferedImageViews;

- (void)loadedPreviewPhotos;

- (void)updatePhotoRotation;

@end
