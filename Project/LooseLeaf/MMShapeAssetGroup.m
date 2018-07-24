//
//  MMShapeAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeAssetGroup.h"
#import "MMShapeAsset.h"


@implementation MMShapeAssetGroup {
    NSArray<MMShapeAsset*>* _shapes;
}


#pragma mark - Singleton

static MMShapeAssetGroup* _instance = nil;

+ (MMShapeAssetGroup*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - MMDisplayAssetGroup

- (instancetype)init {
    if (_instance)
        return _instance;
    if (self = [super init]) {
        NSMutableArray<MMShapeAsset*>* shapes = [NSMutableArray array];

        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 500, 375)] withName:@"Rectangle"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 500, 500)] withName:@"Square"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 500, 500)] withName:@"Circle"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 500, 375) cornerRadius:80] withName:@"RoundedRect"]];

        _shapes = shapes;
    }
    return self;
}

- (NSURL*)assetURL {
    return [NSURL URLWithString:@"loose-leaf://shapes"];
}

- (NSString*)name {
    return @"Shapes";
}

- (NSString*)persistentId {
    return @"LooseLeaf/Shapes";
}

- (NSInteger)numberOfPhotos {
    return [_shapes count];
}

- (NSArray*)previewPhotos {
    return [_shapes subarrayWithRange:NSMakeRange(0, [self numberOfPreviewPhotos])];
}

- (BOOL)reversed {
    return NO;
}

- (short)numberOfPreviewPhotos {
    return 4;
}

- (void)loadPreviewPhotos {
    // noop
}

- (void)unloadPreviewPhotos {
    // noop
}

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* _Nonnull stop) {
        if (idx < [_shapes count]) {
            MMShapeAsset* shape = _shapes[idx];

            enumerationBlock(shape, idx, stop);
        }
    }];
}

@end
