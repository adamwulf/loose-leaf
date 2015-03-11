//
//  MMPDFAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxAssetGroup.h"
#import "MMPDFInboxItem.h"

@interface MMPDFAlbum : MMInboxAssetGroup

-(id) init NS_UNAVAILABLE;

-(id) initWithInboxItem:(MMPDFInboxItem*)pdf;

@end
