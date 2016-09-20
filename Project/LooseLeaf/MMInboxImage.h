//
//  MMInboxImage.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"
#import "MMInboxItem.h"


@interface MMInboxImage : MMDisplayAsset

- (id)init NS_UNAVAILABLE;

- (id)initWithImageItem:(MMInboxItem*)imageItem;

@end
