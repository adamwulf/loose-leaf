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

-(id) initForImage:(UIImage*)imageToDecompress{
    if(self = [super init]){
        image = imageToDecompress;
        decompressBlock = [[MMBlockOperation alloc] initWithBlock:^{
            // this isn't that important since you just want UIImage to decompress the image data before switching back to main thread
            UIGraphicsBeginImageContext(CGSizeMake(1, 1));
            [self.image drawAtPoint:CGPointZero];
            UIGraphicsEndImageContext();
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                @synchronized(self){
                    if(image){
                        isDecompressed = YES;
                        [delegate didDecompressImage:self.image];
                    }
                    decompressBlock = nil;
                }
            });
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
    @synchronized(self){
        if(!isDecompressed){
            [delegate didDecompressImage:nil];
            [decompressBlock cancel];
            image = nil;
            decompressBlock = nil;
        }
    }
}

+(NSOperationQueue*) decompressImageQueue{
    if(!decompressImageQueue){
        @synchronized([MMDecompressImagePromise class]){
            if(!decompressImageQueue){
                decompressImageQueue = [[NSOperationQueue alloc] init];
                decompressImageQueue.maxConcurrentOperationCount = 10;
                decompressImageQueue.name = @"com.milestonemade.looseleaf.decompressImageQueue";
            }
        }
    }
    return decompressImageQueue;
}

@end
