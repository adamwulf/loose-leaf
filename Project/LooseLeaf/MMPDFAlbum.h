//
//  MMPDFAlbum.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"
#import "MMPDF.h"

@interface MMPDFAlbum : MMDisplayAssetGroup

-(id) initWithPDF:(MMPDF*)pdf;

@property (readonly) MMPDF* pdf;

@end
