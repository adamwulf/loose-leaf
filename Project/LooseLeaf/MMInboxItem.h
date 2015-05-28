//
//  MMInboxItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMInboxItem : NSObject

@property (readonly) NSURL* urlOnDisk;

-(id) initWithURL:(NSURL*)itemURL;

-(BOOL) deleteAssets;

-(NSUInteger) pageCount;

-(CGSize) sizeForPage:(NSUInteger)page;

-(UIImage*) thumbnailForPage:(NSUInteger)page;

-(UIImage*) imageForPage:(NSInteger)pageNumber forMaxDim:(CGFloat)maxDim;

-(NSString*) pathForPage:(NSUInteger)pageNumber forMaxDim:(CGFloat)maxDim;

@end
