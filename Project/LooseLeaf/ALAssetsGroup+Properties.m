//
//  ALAssetsGroup+Properties.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "ALAssetsGroup+Properties.h"
#import <DrawKit-iOS/JRSwizzle.h>

@implementation ALAssetsGroup (Properties)

-(NSString*) name{
    return [self valueForProperty:ALAssetsGroupPropertyName];
}

-(ALAssetsGroupType) type{
    return [[self valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
}

-(NSString*) persistentId{
    return [self valueForProperty:ALAssetsGroupPropertyPersistentID];
}

-(NSURL*) url{
    return [self valueForProperty:ALAssetsGroupPropertyURL];
}

-(void) swizzle_dealloc{
    NSLog(@"dealloc %p:%@", self, self.name);
    [self swizzle_dealloc];
}

+(void)load{
    @autoreleasepool {
        NSError *error = nil;
        [ALAssetsGroup jr_swizzleMethod:NSSelectorFromString(@"dealloc")
                            withMethod:@selector(swizzle_dealloc)
                                 error:&error];
    }
}


@end
