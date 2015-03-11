//
//  MMInboxAssetGroup.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"
#import "MMInboxItem.h"

@interface MMInboxAssetGroup : MMDisplayAssetGroup

@property (readonly) MMInboxItem* inboxItem;

-(id) initWithInboxItem:(MMInboxItem*)inboxItem;

@end
