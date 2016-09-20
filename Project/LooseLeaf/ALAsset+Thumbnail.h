//
//  ALAsset+Thumbnail.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@class CLLocation;


@interface ALAsset (Thumbnail)

- (NSString*)type;

- (NSURL*)url;

- (NSDictionary*)urls;

- (CLLocation*)location;

- (NSNumber*)duration;

- (NSNumber*)orientation;

- (NSDate*)date;

- (NSArray*)representations;

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)size;

@end
