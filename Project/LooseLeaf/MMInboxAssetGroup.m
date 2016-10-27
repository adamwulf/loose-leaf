//
//  MMInboxAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxAssetGroup.h"


@implementation MMInboxAssetGroup

@synthesize inboxItem;

- (id)initWithInboxItem:(MMInboxItem*)_inboxItem {
    if (self = [super init]) {
        if (!_inboxItem) {
            @throw [NSException exceptionWithName:@"InboxAssetGroupException" reason:@"Item cannot be nil" userInfo:nil];
        }
        inboxItem = _inboxItem;
    }
    return self;
}

- (NSURL*)assetURL {
    return [inboxItem urlOnDisk];
}

- (NSString*)name {
    return [[inboxItem urlOnDisk] lastPathComponent];
}

- (NSString*)persistentId {
    return [[inboxItem urlOnDisk] path];
}

- (NSInteger)numberOfPhotos {
    return [inboxItem pageCount];
}

@end
