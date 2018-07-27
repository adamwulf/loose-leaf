//
//  MMShapeAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeAssetGroup.h"
#import "MMShapeAsset.h"
#import "UIBezierPath+MMShapes.h"


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

        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 500, 500)] withName:@"Square"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 500, 500)] withName:@"Circle"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath arrowPath] withName:@"Arrow"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath heartPath] withName:@"Heart"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 500, 375) cornerRadius:80] withName:@"RoundedRect"]];

        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath pentagonPath] withName:@"Pentagon"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath trianglePath] withName:@"Triangle"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath hexagonPath] withName:@"Hexagon"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath octagonPath] withName:@"Octagon"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath rombusPath] withName:@"Rombus"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath starPath] withName:@"Star"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath star2Path] withName:@"Star2"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath star3Path] withName:@"Star3"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath trekPath] withName:@"Trek"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath locationPath] withName:@"Location"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath eggPath] withName:@"Egg"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath plusPath] withName:@"Plus"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath diamondPath] withName:@"Diamond"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath infinityPath] withName:@"Infinity"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath tetrisPath] withName:@"Tetris"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath lPath] withName:@"L"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath reverseLPath] withName:@"ReverseL"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath sPath] withName:@"S-shape"]];
        [shapes addObject:[[MMShapeAsset alloc] initWithPath:[UIBezierPath zPath] withName:@"Z-shape"]];


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
