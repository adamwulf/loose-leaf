//
//  MMInboxImageAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxAssetGroup.h"
#import "MMInboxItem.h"

@interface MMInboxImageAlbum : MMInboxAssetGroup

-(id) init NS_UNAVAILABLE;

-(id) initWithInboxItem:(MMInboxItem*)inboxItem;

@end
