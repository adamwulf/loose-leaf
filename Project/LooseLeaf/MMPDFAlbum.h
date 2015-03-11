//
//  MMPDFAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"
#import "MMPDFInboxItem.h"

@interface MMPDFAlbum : MMDisplayAssetGroup

-(id) init NS_UNAVAILABLE;

-(id) initWithPDF:(MMPDFInboxItem*)pdf;

@property (readonly) MMPDFInboxItem* pdf;

@end
