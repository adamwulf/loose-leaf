//
//  ALAsset+Thumbnail.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Thumbnail)

- (UIImage *)aspectThumbnailWithMaxPixelSize:(NSUInteger)size;

@end
