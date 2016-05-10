//
//  MMPDF.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMPDF : NSObject

@property (nonatomic, readonly) NSURL* urlOnDisk;
@property (nonatomic, readonly) NSUInteger pageCount;

-(instancetype) initWithURL:(NSURL*)url;

-(BOOL) attemptToDecrypt:(NSString*)password;

-(BOOL) isEncrypted;

-(CGSize) sizeForPage:(NSUInteger)page;

-(UIImage*) imageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim;

@end
