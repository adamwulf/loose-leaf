//
//  MMLoadImageCache.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMLoadImageCache.h"

#define kThumbCacheSize 30

@implementation MMLoadImageCache{
    NSMutableDictionary* loadedImages;
    NSMutableArray* orderedKeys;
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

+(MMLoadImageCache*) sharedInstace{
    if(!_instance){
        _instance = [[MMLoadImageCache alloc]init];
    }
    return _instance;
}

#pragma mark - Load Images

static int count = 0;
-(UIImage*) imageAtPath:(NSString*)path{
    UIImage* cachedImage = [loadedImages objectForKey:path];
    if(!cachedImage){
        cachedImage = [UIImage imageWithContentsOfFile:path];
        count++;
        @synchronized(self){
            [loadedImages setObject:cachedImage forKey:path];
            [orderedKeys removeObject:path];
            [orderedKeys insertObject:path atIndex:0];
            [self ensureCacheSize];
        }
    }
    return cachedImage;
}

-(void) ensureCacheSize{
    @synchronized(self){
        while([orderedKeys count] > kThumbCacheSize){
            [self clearCacheForPath:[orderedKeys lastObject]];
            [orderedKeys removeLastObject];
        }
    }
}

-(void) clearCacheForPath:(NSString*)path{
    @synchronized(self){
        [loadedImages removeObjectForKey:path];
        [orderedKeys removeObject:path];
    }
}

-(void) updateCacheForPath:(NSString*)path toImage:(UIImage*)image{
    @synchronized(self){
        [self clearCacheForPath:path];
        [loadedImages setObject:image forKey:path];
        [orderedKeys insertObject:path atIndex:0];
        [self ensureCacheSize];
    }
}

@end
