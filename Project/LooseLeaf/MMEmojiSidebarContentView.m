//
//  MMEmojiSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMPhotosPermissionCell.h"
#import "MMPermissionCameraPhotosCollectionViewCell.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "MMCameraCollectionViewCell.h"
#import "MMPhotosListLayout.h"
#import "MMEmojiAssetCell.h"
#import "UIView+Debug.h"
#import "MMAlbumGroupListLayout.h"
#import "Constants.h"
#import "MMBorderedCamView.h"
#import "MMEmojiAssetGroup.h"
#import "MMButtonBoxView.h"
#import "MMColorButton.h"
#import "MMDarkSidebarButton.h"
#import "UIColor+LooseLeaf.h"
#import "NSArray+MapReduce.h"


@interface MMEmojiSidebarContentView (Protected)

- (CGFloat)idealRotationForOrientation;

@end


@implementation MMEmojiSidebarContentView {
    CGPoint lastCameraRollOffset;
    NSArray<MMColorButton*>* colorButtons;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        currentAlbum = [MMEmojiAssetGroup sharedInstance];

        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;

        // remove the photos scroll view so we can add our own constraints
        [photoListScrollView removeFromSuperview];
        [photoListScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [photoListScrollView setAlpha:1];
        [photoListScrollView registerClass:[MMEmojiAssetCell class] forCellWithReuseIdentifier:@"MMEmojiAssetCell"];

        UIView* line = [[UIView alloc] init];
        [line setTranslatesAutoresizingMaskIntoConstraints:NO];
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];

        MMButtonBoxView* colorButtonBox = [[MMButtonBoxView alloc] init];
        colorButtons = @[[[MMColorButton alloc] initWithColor:[UIColor whiteColor] andFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))],
                         [[MMColorButton alloc] initWithColor:[UIColor blueInkColor] andFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))],
                         [[MMColorButton alloc] initWithColor:[UIColor redInkColor] andFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))],
                         [[MMColorButton alloc] initWithColor:[UIColor yellowInkColor] andFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))],
                         [[MMColorButton alloc] initWithColor:[UIColor greenInkColor] andFrame:CGRectFromSize(CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton))]];

        [colorButtonBox setTranslatesAutoresizingMaskIntoConstraints:NO];
        [colorButtonBox setButtons:colorButtons];
        [colorButtonBox sizeToFit];

        [self addSubview:line];
        [self addSubview:colorButtonBox];
        [self addSubview:photoListScrollView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.8 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:14]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:.8 constant:10]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:colorButtonBox attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:14]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:colorButtonBox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:line attribute:NSLayoutAttributeBottom multiplier:.8 constant:10]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:photoListScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:photoListScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:photoListScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:photoListScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:colorButtonBox attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

        [[colorButtons firstObject] setSelected:YES];
        [colorButtons enumerateObjectsUsingBlock:^(MMColorButton* _Nonnull colorButton, NSUInteger idx, BOOL* _Nonnull stop) {
            [colorButton addTarget:self action:@selector(colorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [colorButton setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:.5]];
            [colorButton setBorderColor:[MMDarkSidebarButton borderColor]];
        }];
    }
    return self;
}

- (void)reset:(BOOL)animated {
    // noop
}

- (void)show:(BOOL)animated {
    if (isShowing) {
        [photoListScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    isShowing = YES;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;

    [self updatePhotoRotation:NO];
}

- (void)hide:(BOOL)animated {
    isShowing = NO;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;

    lastCameraRollOffset = photoListScrollView.contentOffset;
}

- (BOOL)hasPermission {
    return YES;
}

- (UICollectionViewLayout*)albumsLayout {
    return [[MMAlbumGroupListLayout alloc] init];
}

- (UICollectionViewLayout*)photosLayout {
    return [[MMPhotosListLayout alloc] initForRotation:[self idealRotationForOrientation]];
}

- (void)updateEmptyErrorMessage {
    // noop
}

- (NSString*)messageTextWhenEmpty {
    return @"No Emojis";
}

#pragma mark - Actions

- (IBAction)colorButtonTapped:(MMColorButton*)button {
    [colorButtons enumerateObjectsUsingBlock:^(MMColorButton* _Nonnull colorButton, NSUInteger idx, BOOL* _Nonnull stop) {
        [colorButton setSelected:colorButton == button];
        [photoListScrollView reloadData];
    }];
}

#pragma mark - Description

- (NSString*)description {
    return @"Emojis";
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    MMEmojiAssetCell* shapeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMEmojiAssetCell" forIndexPath:indexPath];
    [shapeCell loadPhotoFromAlbum:currentAlbum atIndex:indexPath.row];
    shapeCell.delegate = self;
    shapeCell.backgroundColor = [colorButtons reduce:^id(MMColorButton* obj, NSUInteger index, id accum) {
        return [obj isSelected] ? [obj color] : accum;
    }];

    return shapeCell;
}

#pragma mark - MMDisplayAssetCellDelegate

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(UIView<MMDisplayAssetCoordinator>*)bufferedImage withBackgroundColor:(UIColor*)color withRotation:(CGFloat)rotation {
    lastCameraRollOffset = photoListScrollView.contentOffset;

    [super assetWasTapped:asset fromView:bufferedImage withBackgroundColor:color withRotation:rotation];
}

@end
