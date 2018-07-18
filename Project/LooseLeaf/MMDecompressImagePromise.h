//
//  MMDecompressImagePromise.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDecompressImagePromiseDelegate.h"


@interface MMDecompressImagePromise : NSObject {
    UIImage* image;
    __weak NSObject<MMDecompressImagePromiseDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMDecompressImagePromiseDelegate>* delegate;
@property (nonatomic, readonly) UIImage* image;
@property (readonly) BOOL isDecompressed;

- (instancetype)init NS_UNAVAILABLE;

- (id)initForDecompressedImage:(UIImage*)imageToDecompress andDelegate:(NSObject<MMDecompressImagePromiseDelegate>*)delegate;
- (id)initForImage:(UIImage*)imageToDecompress andDelegate:(NSObject<MMDecompressImagePromiseDelegate>*)delegate;

- (void)cancel;

@end
