//
//  MMPDFPage.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"
#import "MMPDFInboxItem.h"

@interface MMPDFPageAsset : MMDisplayAsset

-(id) initWithPDF:(MMPDFInboxItem*)pdf andPage:(NSInteger)pageNum;

@end
