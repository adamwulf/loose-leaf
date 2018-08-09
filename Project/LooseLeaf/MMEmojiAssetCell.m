//
//  MMEmojiAssetCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiAssetCell.h"
#import "MMEmojiOutlineView.h"
#import "MMEmojiAsset.h"
#import "Constants.h"


@implementation MMEmojiAssetCell {
    MMEmojiOutlineView* _emojiView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _emojiView = [[MMEmojiOutlineView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
        _emojiView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_emojiView];

        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [_emojiView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor*)backgroundColor {
    [_emojiView setBackgroundColor:backgroundColor];
}

- (UIColor*)backgroundColor {
    return [_emojiView backgroundColor];
}

#pragma mark - Gesture

- (void)tapped:(id)gesture {
    [[self album] loadPhotosAtIndexes:[[NSIndexSet alloc] initWithIndex:[self index]] usingBlock:^(MMDisplayAsset* result, NSUInteger _index, BOOL* stop) {
        if (result) {
            [[self delegate] assetWasTapped:result fromView:_emojiView withBackgroundColor:_emojiView.backgroundColor withRotation:_emojiView.rotation];
        }
    }];
}

#pragma mark - Properties

- (void)loadPhotoFromAlbum:(MMDisplayAssetGroup*)album atIndex:(NSInteger)photoIndex {
    [super loadPhotoFromAlbum:album atIndex:photoIndex];

    NSIndexSet* assetsToLoad = [[NSIndexSet alloc] initWithIndex:photoIndex];

    [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(MMDisplayAsset* result, NSUInteger index, BOOL* stop) {
        if ([result isKindOfClass:[MMEmojiAsset class]]) {
            [_emojiView setPreferredAspectRatioForEmptyImage:result.fullResolutionSize];
            _emojiView.shape = result;
            _emojiView.image = [(MMEmojiAsset*)result aspectRatioThumbnail];
            _emojiView.rotation = RandomPhotoRotation(photoIndex) + [result defaultRotation];
        }
    }];
}

- (CGFloat)rotation {
    return _emojiView.rotation;
}

- (void)setRotation:(CGFloat)rotation {
    _emojiView.rotation = rotation;

    [super setRotation:rotation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
