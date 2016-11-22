//
//  MMAlbumCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroupCell.h"
#import "MMBufferedImageView.h"
#import "MMRotationManager.h"
#import "NSThread+BlockAdditions.h"
#import "MMTrashButton.h"
#import "Constants.h"


@implementation MMDisplayAssetGroupCell {
    MMTrashButton* deleteButton;
    UILabel* name;
    NSArray* bufferedImageViews;
}

@synthesize album;
@synthesize bufferedImageViews;
@synthesize squishFactor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // load 5 preview image views
        [self initializePositionsForPreviewPhotos];
        bufferedImageViews = [NSArray arrayWithArray:self.subviews];

        CGFloat deleteButtonWidth = 80;
        CGRect deleteRect = CGRectMake(self.bounds.size.width - 80 - kBounceWidth, (self.bounds.size.height - deleteButtonWidth) / 2, deleteButtonWidth, deleteButtonWidth);
        deleteButton = [[MMTrashButton alloc] initWithFrame:deleteRect];
        [deleteButton addTarget:self action:@selector(deleteButtonTappedDown:forEvent:) forControlEvents:UIControlEventTouchDown];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.rotation = M_PI / 4;
        deleteButton.transform = [deleteButton rotationTransform];
        deleteButton.alpha = 0;
        [self addSubview:deleteButton];

        // clarity
        self.opaque = NO;
        //        self.clipsToBounds = YES;

        [self updatePhotoRotation];
    }
    return self;
}

- (MMBufferedImageView*)previewViewForImage:(int)i {
    MMBufferedImageView* imgView;
    int trueIndex = 5 - i - 1;
    if ([self.subviews count] > 5) {
        imgView = [self.subviews objectAtIndex:trueIndex];
    } else {
        imgView = [[MMBufferedImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
        [self insertSubview:imgView atIndex:0];
    }
    return imgView;
}

- (void)initializePositionsForPreviewPhotos {
    CGFloat currX = 2 * kBounceWidth;
    CGFloat maxDim = self.bounds.size.height;
    CGFloat stepX = (self.bounds.size.width - maxDim - currX) / 4;
    for (int i = 0; i < 5; i++) {
        MMBufferedImageView* imgView = [self previewViewForImage:i];
        imgView.bounds = CGRectMake(0, 0, maxDim, maxDim);
        CGFloat rot = RandomPhotoRotation(i);
        imgView.rotation = visiblePhotoRotation + rot;
        imgView.center = CGPointMake(currX + maxDim / 2, maxDim / 2);
        initialX[5 - i - 1] = imgView.center.x;
        finalX[5 - i - 1] = imgView.center.x - (i + 1) * stepX / 2;
        initRot[5 - i - 1] = rot;
        rotAdj[5 - i - 1] = RandomPhotoRotation(i + 1);
        adjY[5 - i - 1] = (4 + rand() % 4) * (i % 2 ? 1 : -1);
        currX += stepX;
    }
}

- (void)deleteButtonTapped:(id)sender forEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTappedDown object:[[event touchesForView:sender] anyObject]];
    [[NSThread mainThread] performBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event touchesForView:sender] anyObject]];
        [[NSThread mainThread] performBlock:^{
            [self.delegate deleteButtonWasTappedForCell:self];
        } afterDelay:.2];
    } afterDelay:.2];
}
- (void)deleteButtonTappedDown:(id)sender forEvent:(UIEvent*)event {
    [self.delegate deleteButtonWasTappedForCell:self];
}


- (void)setAlbum:(MMDisplayAssetGroup*)_album {
    if (album != _album) {
        album = _album;
        [album loadPreviewPhotos];
        name.text = album.name;
        [self loadedPreviewPhotos];
    }
}

#pragma mark - MMPhotoAlbumDelegate;

- (void)loadedPreviewPhotos {
    for (int i = 0; i < 5; i++) {
        MMDisplayAsset* img = nil;
        int indexOfPhoto = 4 - i;
        if (indexOfPhoto < [album.previewPhotos count]) {
            img = [album.previewPhotos objectAtIndex:indexOfPhoto];
        }
        MMBufferedImageView* v = [bufferedImageViews objectAtIndex:i];
        if (img) {
            [v setPreferredAspectRatioForEmptyImage:img.fullResolutionSize];
            [v setImage:img.aspectRatioThumbnail];
            v.hidden = NO;
        } else {
            v.image = nil;
            v.hidden = YES;
        }
    }
}

#pragma mark - Rotation

- (void)updatePhotoRotation {
    UIInterfaceOrientation orient = [[MMRotationManager sharedInstance] lastBestOrientation];
    if (orient == UIInterfaceOrientationLandscapeRight) {
        visiblePhotoRotation = M_PI / 2;
    } else if (orient == UIInterfaceOrientationPortraitUpsideDown) {
        visiblePhotoRotation = M_PI;
    } else if (orient == UIInterfaceOrientationLandscapeLeft) {
        visiblePhotoRotation = -M_PI / 2;
    } else {
        visiblePhotoRotation = 0;
    }

    int i = 0;
    for (MMBufferedImageView* imageView in bufferedImageViews) {
        if ([imageView isKindOfClass:[MMBufferedImageView class]]) {
            imageView.rotation = visiblePhotoRotation + RandomPhotoRotation(i);
        }
        i++;
    }
}

#pragma mark - Swipe for Delete

// must be called after adjustForDelete
- (BOOL)finishSwipeToDelete {
    if (squishFactor < .8) {
        // bounce back to zero and hide delete button
        [UIView animateWithDuration:.2 animations:^{
            CGFloat bounce = ABS(squishFactor * .2);
            [self adjustForDelete:(squishFactor < 0) ? bounce : -bounce];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                [self adjustForDelete:0];
                deleteButton.alpha = 0;
            }];
        }];
        return NO;
    } else if (squishFactor > 1.9) {
        // bypass tapping the delete button and just
        // delete immediately
        return YES;
    } else {
        // bounce to show delete button
        [UIView animateWithDuration:.2 animations:^{
            CGFloat bounce = ABS(1.0 - squishFactor) * .2;
            [self adjustForDelete:(squishFactor < 1.0) ? (1 + bounce) : (1 - bounce)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                [self adjustForDelete:1.0];
                deleteButton.alpha = 1.0;
            }];
        }];
        return NO;
    }
}

- (void)resetDeleteAdjustment:(BOOL)animated {
    if (animated) {
        if (squishFactor != 0) {
            squishFactor = .8; // for bounce
            [UIView animateWithDuration:.2 animations:^{
                CGFloat bounce = ABS(squishFactor * .2);
                [self adjustForDelete:(squishFactor < 0) ? bounce : -bounce];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1 animations:^{
                    [self adjustForDelete:0];
                    deleteButton.alpha = 0;
                }];
            }];
        }
    } else {
        [self adjustForDelete:0];
        [self.layer removeAllAnimations];
    }
}

- (void)adjustForDelete:(CGFloat)adjustment {
    if ([self.layer.animationKeys count]) {
        [self.layer removeAllAnimations];
    }
    squishFactor = MAX(-0.2, adjustment);

    CGFloat alphaForDelete = adjustment - .5;
    alphaForDelete = MAX(alphaForDelete, 0);
    alphaForDelete /= .4;
    alphaForDelete = MIN(alphaForDelete, 1.0);
    deleteButton.alpha = alphaForDelete;


    for (int i = 0; i < 5; i++) {
        CGFloat ix = initialX[i];
        CGFloat fx = finalX[i];
        CGFloat diff = fx - ix;
        CGFloat x = ix + diff * squishFactor;

        MMBufferedImageView* imgView = [bufferedImageViews objectAtIndex:i];
        CGPoint c = imgView.center;
        c.x = x;
        c.y = self.bounds.size.height / 2 + adjY[i] * squishFactor;
        imgView.center = c;

        imgView.rotation = visiblePhotoRotation + initRot[i] + squishFactor * rotAdj[i];
    }
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTappedDown object:[[event allTouches] anyObject]];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event allTouches] anyObject]];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event allTouches] anyObject]];
    [super touchesCancelled:touches withEvent:event];
}

@end
