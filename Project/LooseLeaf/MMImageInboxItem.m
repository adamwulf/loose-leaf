//
//  MMImageInboxItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMImageInboxItem.h"
#import "MMInboxItem+Protected.h"
#import "Constants.h"

@implementation MMImageInboxItem{
    CGSize cachedSize;
}

-(NSUInteger) pageCount{
    return 1;
}

-(CGSize) sizeForPage:(NSUInteger)page{
    if(CGSizeEqualToSize(cachedSize, CGSizeZero)){
        @autoreleasepool {
            UIImage* img = [UIImage imageWithContentsOfFile:[self.urlOnDisk path]];
            cachedSize = img.size;
        }
    }
    return cachedSize;
}


@end
