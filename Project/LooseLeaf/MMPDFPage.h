//
//  MMPDFPage.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPhoto.h"
#import "MMPDF.h"

@interface MMPDFPage : MMPhoto

-(id) initWithALAsset:(ALAsset*)asset NS_UNAVAILABLE;

-(id) initWithPDF:(MMPDF*)pdf andPage:(NSInteger)pageNum;

@end
