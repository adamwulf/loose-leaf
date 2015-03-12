//
//  MMInboxItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxItem.h"
#import "Constants.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSString+MD5.h"
#import "MMLoadImageCache.h"

@implementation MMInboxItem{
    NSURL* itemURL;
    NSString* cachedAssetsPath;
    NSMutableDictionary* pageSizeCache;
}

#pragma mark - Queues

static dispatch_queue_t assetQueue;
static const void *const kInboxAssetQueueIdentifier = &kInboxAssetQueueIdentifier;

+(dispatch_queue_t) assetQueue{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetQueue = dispatch_queue_create("com.milestonemade.looseleaf.inboxAssetQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(assetQueue, kInboxAssetQueueIdentifier, (void *)kInboxAssetQueueIdentifier, NULL);
    });
    return assetQueue;
}

#pragma mark - Init

-(id) initWithURL:(NSURL *)_itemURL{
    @throw kAbstractMethodException;
}

-(id) initWithURL:(NSURL *)_itemURL andInitBlock:(void(^)())block{
    if(self = [super init]){
        itemURL = _itemURL;
        pageSizeCache = [NSMutableDictionary dictionary];
        if(block) block();
        [self generatePageThumbnailCache];
    }
    return self;
}

#pragma mark - Properties

-(NSURL*) urlOnDisk{
    return itemURL;
}

-(NSString*) cachedAssetsPath{
    if(!cachedAssetsPath){
        NSString* relativeToDocuments = [itemURL path];
        relativeToDocuments = [relativeToDocuments stringByReplacingOccurrencesOfString:[NSFileManager documentsPath]
                                                                             withString:@""
                                                                                options:NSCaseInsensitiveSearch
                                                                                  range:NSMakeRange(0, [relativeToDocuments length])];
        NSString* pdfHash = [relativeToDocuments MD5Hash];
        NSLog(@"generating path: %@ to %@", relativeToDocuments, pdfHash);
        cachedAssetsPath = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"PDFCache"] stringByAppendingPathComponent:pdfHash];
        [NSFileManager ensureDirectoryExistsAtPath:cachedAssetsPath];
    }
    return cachedAssetsPath;
}

#pragma mark - Public

-(UIImage*) imageForPage:(NSInteger)pageNumber forMaxDim:(CGFloat)maxDim{
    NSString* cachedImagePath = [self pathForPage:pageNumber forMaxDim:maxDim];
    
    UIImage* pageThumb = [self cachedImageAtPath:cachedImagePath];
    if(!pageThumb){
        @autoreleasepool {
            pageThumb = [self generateImageForPage:pageNumber withMaxDim:maxDim];
            BOOL success = [UIImagePNGRepresentation(pageThumb) writeToFile:cachedImagePath atomically:YES];
            if(!success){
                NSLog(@"generating %@ thumbnail failed", NSStringFromClass([self class]));
            }
            if(cachedImagePath){
                [[MMLoadImageCache sharedInstance] updateCacheForPath:cachedImagePath toImage:pageThumb];
            }
        }
    }
    return pageThumb;
}

-(CGSize) sizeForPage:(NSUInteger)page{
    @synchronized(self){
        // first check the cache and see if we have it
        // calculated already
        if([pageSizeCache objectForKey:@(page)]){
            return [[pageSizeCache objectForKey:@(page)] CGSizeValue];
        }else{
            CGSize calcSize = [self calculateSizeForPage:page];
            [pageSizeCache setObject:[NSValue valueWithCGSize:calcSize] forKey:@(page)];
            return calcSize;
        }
    }
}

-(NSString*) pathForPage:(NSUInteger)pageNumber forMaxDim:(CGFloat)maxDim{
    NSString* cachedImagePath = [NSString stringWithFormat:@"thumb%d-%d.png",(int) pageNumber,(int)maxDim];
    cachedImagePath = [[self cachedAssetsPath] stringByAppendingPathComponent:cachedImagePath];
    return cachedImagePath;
}


#pragma mark - Override

-(NSUInteger) pageCount{
    @throw kAbstractMethodException;
}

-(UIImage*) thumbnailForPage:(NSUInteger)page{
    return [self cachedImageAtPath:[self pathForPage:page forMaxDim:kThumbnailMaxDim]];
}

-(CGSize) calculateSizeForPage:(NSUInteger)page{
    @throw kAbstractMethodException;
}

-(UIImage*) generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    @throw kAbstractMethodException;
}

-(void) generatePageThumbnailCache{
    dispatch_async([MMInboxItem assetQueue], ^{
        @synchronized(self){
            [pageSizeCache removeAllObjects];
        }
        NSLog(@"generating page thumbnails: %d",(int) [self pageCount]);
        for(int pageNumber=0;pageNumber<[self pageCount];pageNumber++){
            [self imageForPage:pageNumber forMaxDim:kThumbnailMaxDim];
            @synchronized(self){
                [pageSizeCache setObject:[NSValue valueWithCGSize:[self sizeForPage:pageNumber]] forKey:@(pageNumber)];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kInboxItemThumbnailGenerated object:self userInfo:@{@"pageNumber":@(pageNumber)}];
        }
    });
}

#pragma mark - Dealloc and Delete

-(BOOL) deleteAssets{
    NSError* errorURL = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.urlOnDisk path] error:&errorURL];
    
    dispatch_async([MMInboxItem assetQueue], ^{
        // delete cached assets on background queue
        // since there might be a lot of them
        NSError* errorCache = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[self cachedAssetsPath] error:&errorCache];
        
        if(errorCache){
            NSLog(@"delete PDF cache erorr: %@", errorCache);
        }
    });

    if(errorURL){
        NSLog(@"delete InboxItem erorr: %@", errorURL);
        return YES;
    }
    return NO;
}

#pragma mark - Private

-(UIImage*) cachedImageAtPath:(NSString*)cachedImagePath{
    UIImage* pageThumb = nil;
    @autoreleasepool {
        if(cachedImagePath && [[NSFileManager defaultManager] fileExistsAtPath:cachedImagePath]){
            return [[MMLoadImageCache sharedInstance] imageAtPath:cachedImagePath];
        }
    }
    return pageThumb;
}





@end
