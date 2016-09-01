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
        dispatch_set_target_queue(assetQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
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
        pageSizeCache = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForSizeCache]] mutableCopy];
        if(!pageSizeCache){
            pageSizeCache = [NSMutableDictionary dictionary];
        }
        if(block) block();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self generatePageThumbnailCache];
        });
    }
    return self;
}

#pragma mark - Properties

-(NSURL*) urlOnDisk{
    return itemURL;
}

+(NSString*) cacheDirectory{
    return [[NSFileManager documentsPath] stringByAppendingPathComponent:@"PDFCache"];
}

-(NSString*) cachedAssetsPath{
    if(!cachedAssetsPath){
        NSString* relativeToDocuments = [itemURL path];
        relativeToDocuments = [relativeToDocuments stringByReplacingOccurrencesOfString:[NSFileManager documentsPath]
                                                                             withString:@""
                                                                                options:NSCaseInsensitiveSearch
                                                                                  range:NSMakeRange(0, [relativeToDocuments length])];
        NSString* pdfHash = [relativeToDocuments MD5Hash];

        cachedAssetsPath = [[MMInboxItem cacheDirectory] stringByAppendingPathComponent:pdfHash];
        [NSFileManager ensureDirectoryExistsAtPath:cachedAssetsPath];
    }
    return cachedAssetsPath;
}

#pragma mark - Public

-(CGFloat) rotationForPage:(NSInteger)pageNumber{
    return 0;
}

-(UIImage*) imageForPage:(NSInteger)pageNumber forMaxDim:(CGFloat)maxDim{
    return [self imageForPage:pageNumber forMaxDim:maxDim andSaveToDiskCache:maxDim == kThumbnailMaxDim];
}

-(UIImage*) imageForPage:(NSInteger)pageNumber forMaxDim:(CGFloat)maxDim andSaveToDiskCache:(BOOL)saveToCache{
    NSString* cachedImagePath = [self pathForPage:pageNumber forMaxDim:maxDim];
    
    UIImage* pageThumb = [self cachedImageAtPath:cachedImagePath];
    if(!pageThumb){
        @autoreleasepool {
            pageThumb = [self generateImageForPage:pageNumber withMaxDim:maxDim];
            if(saveToCache){
                BOOL success = [UIImagePNGRepresentation(pageThumb) writeToFile:cachedImagePath atomically:YES];
                if(!success){
                    DebugLog(@"generating %@ thumbnail failed", NSStringFromClass([self class]));
                }
            }
            if(cachedImagePath){
                // memory cache only
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
            NSDictionary* d = [pageSizeCache objectForKey:@(page)];
            return CGSizeMake([d[@"width"] floatValue], [d[@"height"] floatValue]);
        }else{
            CGSize calcSize = [self calculateSizeForPage:page];
            [pageSizeCache setObject:@{@"width": @(calcSize.width), @"height": @(calcSize.height) } forKey:@(page)];
            return calcSize;
        }
    }
}

-(NSString*) pathForPage:(NSUInteger)pageNumber forMaxDim:(CGFloat)maxDim{
    NSString* cachedImagePath = [NSString stringWithFormat:@"thumb%d-%d.png",(int) pageNumber,(int)maxDim];
    cachedImagePath = [[self cachedAssetsPath] stringByAppendingPathComponent:cachedImagePath];
    return cachedImagePath;
}

-(NSString*) pathForSizeCache{
    NSString* cachedSizePath = [NSString stringWithFormat:@"sizeCache.plist"];
    cachedSizePath = [[self cachedAssetsPath] stringByAppendingPathComponent:cachedSizePath];
    return cachedSizePath;
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
        @autoreleasepool {
            for(int pageNumber=0;pageNumber<[self pageCount];pageNumber++){
                if(![[NSFileManager defaultManager] fileExistsAtPath:[self pathForPage:pageNumber forMaxDim:kThumbnailMaxDim]]){
                    [self imageForPage:pageNumber forMaxDim:kThumbnailMaxDim];
                }
                @synchronized(self){
                    CGSize s = [self sizeForPage:pageNumber];
                    [pageSizeCache setObject:@{@"width": @(s.width), @"height": @(s.height) } forKey:@(pageNumber)];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kInboxItemThumbnailGenerated object:self userInfo:@{@"pageNumber":@(pageNumber)}];
            }
            [NSKeyedArchiver archiveRootObject:[pageSizeCache copy] toFile:[self pathForSizeCache]];
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
            DebugLog(@"delete PDF cache erorr: %@", errorCache);
        }
    });

    if(errorURL){
        DebugLog(@"delete InboxItem erorr: %@", errorURL);
        return YES;
    }
    return NO;
}

#pragma mark - Private

-(UIImage*) cachedImageAtPath:(NSString*)cachedImagePath{
    UIImage* pageThumb = nil;
    @autoreleasepool {
        BOOL containsPathAlready = [[MMLoadImageCache sharedInstance] containsPathInCache:cachedImagePath];
        if(cachedImagePath && (containsPathAlready || [[NSFileManager defaultManager] fileExistsAtPath:cachedImagePath])){
            return [[MMLoadImageCache sharedInstance] imageAtPath:cachedImagePath];
        }
    }
    return pageThumb;
}





@end
