//
//  MMAlbumRowView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPhotoAlbumDelegate.h"
#import "MMPhotoAlbum.h"

@interface MMAlbumRowView : UIView<MMPhotoAlbumDelegate>

- (id)initWithFrame:(CGRect)frame andAlbum:(MMPhotoAlbum*)_album;

@end
