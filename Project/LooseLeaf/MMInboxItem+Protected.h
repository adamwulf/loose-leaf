//
//  MMInboxItem+Protected.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxItem.h"

@interface MMInboxItem (Protected)

+(dispatch_queue_t) assetQueue;

+(NSString*) cacheDirectory;

-(id) initWithURL:(NSURL*)itemURL andInitBlock:(void(^)())block;

-(void) generatePageThumbnailCache;

-(CGSize) calculateSizeForPage:(NSUInteger)page;

-(UIImage*) cachedImageAtPath:(NSString*)cachedImagePath;

-(UIImage*) generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim;

-(NSString*) cachedAssetsPath;


@end
