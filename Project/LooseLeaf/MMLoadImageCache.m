//
//  MMLoadImageCache.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMLoadImageCache.h"
#import "Constants.h"

// TODO: possibly use this tutorial for threadsafe cache
// https://mikeash.com/pyblog/friday-qa-2011-10-14-whats-new-in-gcd.html

@implementation MMLoadImageCache{
    NSMutableDictionary* loadedImages;
    NSMutableArray* orderedKeys;
    int loadedBytes;
}

static MMLoadImageCache* _instance = nil;

-(id) init{
    @synchronized([MMLoadImageCache class]){
        if(_instance) return _instance;
        if((self = [super init])){
            loadedImages = [NSMutableDictionary dictionary];
            orderedKeys = [NSMutableArray array];
            _instance = self;
        }
    }
    return _instance;
}

+(MMLoadImageCache*) sharedInstance{
    if(!_instance){
        _instance = [[MMLoadImageCache alloc]init];
    }
    return _instance;
}

-(int) memoryOfLoadedImages{
    return loadedBytes;
}

#pragma mark - Load Images

-(BOOL) containsPathInCache:(NSString*)path{
    BOOL contains = NO;
    @synchronized(self){
        contains = [orderedKeys containsObject:path];
    }
    return contains;
}


static int count = 0;
-(UIImage*) imageAtPath:(NSString*)path{
    UIImage* cachedImage = nil;
    @synchronized(self){
        cachedImage = [loadedImages objectForKey:path];
    }
    if(!cachedImage){
        @synchronized(self){
            if([orderedKeys containsObject:path]){
                // we don't have an image, but our path is
                // in cache. this means there was nothing on disk
                return nil;
            }
        }
        cachedImage = [UIImage imageWithContentsOfFile:path];
        count++;
        @synchronized(self){
            if(cachedImage){
                [loadedImages setObject:cachedImage forKey:path];
            }
            [orderedKeys removeObject:path];
            [orderedKeys insertObject:path atIndex:0];
            [self ensureCacheSize];
            
            loadedBytes += cachedImage.size.width * cachedImage.scale * cachedImage.size.height * cachedImage.scale * 4;
        }
    }
    return cachedImage;
}

-(void) ensureCacheSize{
    @synchronized(self){
        while([orderedKeys count] > kMMLoadImageCacheSize){
            [self clearCacheForPath:[orderedKeys lastObject]];
        }
    }
}

-(void) clearCacheForPath:(NSString*)path{
    @synchronized(self){
        UIImage* cachedImage = [loadedImages objectForKey:path];
        if(cachedImage){
            loadedBytes -= cachedImage.size.width * cachedImage.size.height * 4;
        }
        [loadedImages removeObjectForKey:path];
        [orderedKeys removeObject:path];
    }
}

-(void) updateCacheForPath:(NSString*)path toImage:(UIImage*)image{
    @synchronized(self){
        [self clearCacheForPath:path];
        if(image){
            UIImage* cachedImage = [loadedImages objectForKey:path];
            if(cachedImage){
                loadedBytes -= cachedImage.size.width * cachedImage.size.height * 4;
            }
            [loadedImages setObject:image forKey:path];
            loadedBytes += image.size.width * image.scale * image.size.height * image.scale * 4;
        }else{
            UIImage* cachedImage = [loadedImages objectForKey:path];
            if(cachedImage){
                loadedBytes -= cachedImage.size.width * cachedImage.scale * cachedImage.size.height * cachedImage.scale * 4;
            }
            [loadedImages removeObjectForKey:path];
        }
        [orderedKeys insertObject:path atIndex:0];
        [self ensureCacheSize];
    }
}

#pragma mark - Profiling Helpers

-(NSInteger) numberOfItemsHeldInCache{
    return [loadedImages count];
}

@end
