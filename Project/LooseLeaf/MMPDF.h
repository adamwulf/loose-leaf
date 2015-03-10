//
//  MMPDF.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMPDF : NSObject

@property (readonly) BOOL isEncrypted;

-(BOOL) attemptToDecrypt:(NSString*)password;

-(id) initWithURL:(NSURL*)pdfURL;

-(NSURL*) urlOnDisk;

-(NSUInteger) pageCount;

-(CGSize) sizeForPage:(NSUInteger)page;

-(UIImage*) thumbnailForPage:(NSUInteger)page;

-(UIImage*) imageForPage:(NSInteger)pageNumber withMaxDim:(CGFloat)maxDim;

-(NSURL*) imageURLForPage:(NSUInteger)page;

-(BOOL) deleteAssets;

@end
