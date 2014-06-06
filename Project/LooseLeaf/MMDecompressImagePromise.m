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

NSOperationQueue* decompressImageQueue;

@implementation MMDecompressImagePromise{
    MMBlockOperation* decompressBlock;
    BOOL isDecompressed;
}

@synthesize delegate;
@synthesize image;
@synthesize isDecompressed;

-(id) initForDecompressedImage:(UIImage*)imageToDecompress{
    if(self = [super init]){
        image = imageToDecompress;
        isDecompressed = YES;
    }
    return self;
}

-(void) setIsDecompressed:(BOOL)_isDecompressed{
    isDecompressed = _isDecompressed;
}

-(id) initForImage:(UIImage*)imageToDecompress{
    if(self = [super init]){
        image = imageToDecompress;
        __weak MMDecompressImagePromise* weakSelf = self;
        void (^notifyDelegateBlock)() = ^(void) {
            @autoreleasepool {
                MMDecompressImagePromise* strongMainSelf = weakSelf;
                @synchronized(strongMainSelf){
                    if(strongMainSelf && strongMainSelf.image){
                        strongMainSelf.isDecompressed = YES;
                        [strongMainSelf.delegate didDecompressImage:strongMainSelf.image];
                    }
                }
            }
        };
        __weak void (^weakNotifyDelegateBlock)() = notifyDelegateBlock;
        
        decompressBlock = [[MMBlockOperation alloc] initWithBlock:^{
            @autoreleasepool {
                // this isn't that important since you just want UIImage to decompress the image data before switching back to main thread
                MMDecompressImagePromise* strongContextSelf = weakSelf;
                void (^strongNotifyDelegateBlock)() = weakNotifyDelegateBlock;
                if(strongContextSelf){
                    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
                    [strongContextSelf.image drawAtPoint:CGPointZero];
                    UIGraphicsEndImageContext();
                    if(strongNotifyDelegateBlock){
                        dispatch_async(dispatch_get_main_queue(), strongNotifyDelegateBlock);
                    }else{
                        NSObject<MMDecompressImagePromiseDelegate>* strongDelegate = strongContextSelf.delegate;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongDelegate didDecompressImage:nil];
                        });
                    }
                }
            }
        }];
        [[MMDecompressImagePromise decompressImageQueue] addOperation:decompressBlock];
    }
    return self;
}

-(void) setDelegate:(NSObject<MMDecompressImagePromiseDelegate> *)_delegate{
    @synchronized(self){
        delegate = _delegate;
        if(isDecompressed){
            [_delegate didDecompressImage:image];
        }
    }
}

-(void) cancel{
    @autoreleasepool {
        NSObject<MMDecompressImagePromiseDelegate>* strongDelegate = delegate;;
        delegate = nil;
        [NSThread performBlockOnMainThreadSync:^{
            if(!isDecompressed){
                [strongDelegate didDecompressImage:nil];
            }
        }];
        @synchronized(self){
            if(!isDecompressed){
                [decompressBlock cancel];
                image = nil;
                decompressBlock = nil;
            }
        }
    }
}

+(NSOperationQueue*) decompressImageQueue{
    if(!decompressImageQueue){
        @synchronized([MMDecompressImagePromise class]){
            if(!decompressImageQueue){
                decompressImageQueue = [[NSOperationQueue alloc] init];
                decompressImageQueue.maxConcurrentOperationCount = 3;
                decompressImageQueue.name = @"com.milestonemade.looseleaf.decompressImageQueue";
            }
        }
    }
    return decompressImageQueue;
}

@end
