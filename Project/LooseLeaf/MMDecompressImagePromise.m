//
//  MMDecompressImagePromise.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDecompressImagePromise.h"
#import "MMBlockOperation.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

NSOperationQueue* decompressImageQueue;

@interface MMDecompressImagePromise ()

@property (nonatomic) UIImage* image;

@end

@implementation MMDecompressImagePromise {
    MMBlockOperation* decompressBlock;
    BOOL isDecompressed;
}

@synthesize delegate;
@synthesize image;
@synthesize isDecompressed;

- (id)initForDecompressedImage:(UIImage*)imageToDecompress andDelegate:(NSObject<MMDecompressImagePromiseDelegate>*)_delegate {
    if (self = [super init]) {
        delegate = _delegate;
        image = imageToDecompress;
        isDecompressed = YES;
    }
    return self;
}

- (id)initForImage:(UIImage*)imageToDecompress andDelegate:(NSObject<MMDecompressImagePromiseDelegate>*)_delegate {
    if (self = [super init]) {
        delegate = _delegate;
        image = imageToDecompress;
        __weak MMDecompressImagePromise* weakSelf = self;

        decompressBlock = [[MMBlockOperation alloc] initWithBlock:^{
            @autoreleasepool {
                CheckAnyThreadExcept([NSThread isMainThread]);
                // this isn't that important since you just want UIImage to decompress the image data before switching back to main thread
                MMDecompressImagePromise* strongContextSelf = weakSelf;
                if (strongContextSelf) {
                    UIImage* imgToDecompress = strongContextSelf.image;
                    if (imgToDecompress) {
                        UIGraphicsBeginImageContext(CGSizeMake(imgToDecompress.size.width, imgToDecompress.size.height));
                        [imgToDecompress drawAtPoint:CGPointZero];
                        strongContextSelf.image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        @autoreleasepool {
                            BOOL shouldNotify = NO;
                            @synchronized(strongContextSelf) {
                                if (strongContextSelf && strongContextSelf.image) {
                                    strongContextSelf.isDecompressed = YES;
                                    shouldNotify = YES;
                                }
                            }
                            if(shouldNotify){
                                [strongContextSelf.delegate didDecompressImage:strongContextSelf];
                            }
                        }
                    });
                }
            }
        }];
        [[MMDecompressImagePromise decompressImageQueue] addOperation:decompressBlock];
    }
    return self;
}


- (void)setIsDecompressed:(BOOL)_isDecompressed {
    isDecompressed = _isDecompressed;
}

- (void)setDelegate:(NSObject<MMDecompressImagePromiseDelegate>*)_delegate {
    @synchronized(self) {
        delegate = _delegate;
        if (isDecompressed) {
            [_delegate didDecompressImage:self];
        }
    }
}

- (void)cancel {
    @autoreleasepool {
        NSObject<MMDecompressImagePromiseDelegate>* strongDelegate = delegate;
        delegate = nil;
        [NSThread performBlockOnMainThreadSync:^{
            if (!isDecompressed) {
                [strongDelegate didDecompressImage:nil];
            }
        }];
        @synchronized(self) {
            if (!isDecompressed) {
                [decompressBlock cancel];
                image = nil;
                decompressBlock = nil;
            }
        }
    }
}

+ (NSOperationQueue*)decompressImageQueue {
    if (!decompressImageQueue) {
        @synchronized([MMDecompressImagePromise class]) {
            if (!decompressImageQueue) {
                decompressImageQueue = [[NSOperationQueue alloc] init];
                decompressImageQueue.maxConcurrentOperationCount = 3;
                decompressImageQueue.name = @"com.milestonemade.looseleaf.decompressImageQueue";
            }
        }
    }
    return decompressImageQueue;
}

@end
