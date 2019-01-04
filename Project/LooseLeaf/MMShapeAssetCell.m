//
//  MMShapeAssetCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeAssetCell.h"
#import "MMShapeOutlineView.h"
#import "MMShapeAsset.h"
#import "Constants.h"


@implementation MMShapeAssetCell {
    MMShapeOutlineView* _shapeView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _shapeView = [[MMShapeOutlineView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
        _shapeView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_shapeView];

        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [_shapeView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor*)backgroundColor {
    [_shapeView setBackgroundColor:backgroundColor];
}

- (UIColor*)backgroundColor {
    return [_shapeView backgroundColor];
}

#pragma mark - Gesture

- (void)tapped:(id)gesture {
    [[self album] loadPhotosAtIndexes:[[NSIndexSet alloc] initWithIndex:[self index]] usingBlock:^(MMDisplayAsset* result, NSUInteger _index, BOOL* stop) {
        if (result) {
            [[self delegate] assetWasTapped:result fromView:_shapeView withBackgroundColor:_shapeView.backgroundColor withRotation:_shapeView.rotation];
        }
    }];
}

#pragma mark - Properties

- (void)loadPhotoFromAlbum:(MMDisplayAssetGroup*)album atIndex:(NSInteger)photoIndex {
    [super loadPhotoFromAlbum:album atIndex:photoIndex];

    NSIndexSet* assetsToLoad = [[NSIndexSet alloc] initWithIndex:photoIndex];

    [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(MMDisplayAsset* result, NSUInteger index, BOOL* stop) {
        if ([result isKindOfClass:[MMShapeAsset class]]) {
            [_shapeView setPreferredAspectRatioForEmptyImage:result.fullResolutionSize];
            _shapeView.shape = result.fullResolutionPath;
            _shapeView.rotation = RandomPhotoRotation(photoIndex) + [result defaultRotation];
        }
    }];
}

- (CGFloat)rotation {
    return _shapeView.rotation;
}

- (void)setRotation:(CGFloat)rotation {
    _shapeView.rotation = rotation;

    [super setRotation:rotation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
