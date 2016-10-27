//
//  MMCameraListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/7/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraListLayout.h"
#import "CaptureSessionManager.h"
#import "MMPhotosPermissionCell.h"
#import "MMPhotoManager.h"
#import "Constants.h"


@implementation MMCameraListLayout {
    CGFloat rotation;
}

@synthesize rotation;

- (id)initForRotation:(CGFloat)_rotation {
    if (self = [super initForRotation:_rotation]) {
        rotation = _rotation;
    }
    return self;
}

- (BOOL)hasCameraPermission {
    return [CaptureSessionManager hasCamera] && [CaptureSessionManager hasCameraPermission];
}

- (BOOL)hasPermission {
    return [super hasPermission] || [self hasCameraPermission];
}

- (CGFloat)photoRowHeight {
    return self.collectionView.bounds.size.width / 2;
}

- (NSInteger)sectionIndexForPhotos {
    return [self hasPermission] ? 1 : 0;
}

- (CGFloat)cameraRowHeight {
    if ([self hasPermission]) {
        if ([self hasCameraPermission]) {
            return [self photoRowHeight] * 2 + kCameraMargin;
        } else {
            return [self photoRowHeight] * [MMPhotosPermissionCell idealPhotoRowHeight] + kCameraMargin;
        }
    }
    return [super cameraRowHeight];
}


- (CGSize)collectionViewContentSize {
    CGSize contentSize = [super collectionViewContentSize];
    return CGSizeMake(contentSize.width, contentSize.height + [self cameraRowHeight]);
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];


    if (indexPath.section == 0 && [self hasCameraPermission]) {
        // show camera
        CGFloat width = self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer;
        ret.bounds = CGRectMake(0, 0, width, [self cameraRowHeight]);
        ret.center = CGPointMake(self.collectionView.bounds.size.width / 2, [self cameraRowHeight] / 2);
        ret.transform = CGAffineTransformIdentity;
        return ret;
    } else if (indexPath.section == 0 && ![self hasCameraPermission]) {
        CGFloat width = self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer;
        // don't have camera permissions
        ret.bounds = CGRectMake(0, 0, width, [self cameraRowHeight]);
        ret.center = CGPointMake(self.collectionView.bounds.size.width / 2 + kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer + [self cameraRowHeight] / 2);
        ret.transform = CGAffineTransformIdentity;
        return ret;
    }

    ret = [super layoutAttributesForItemAtIndexPath:indexPath];
    // adjust for camera
    if ([self hasPermission]) {
        ret.center = CGPointMake(ret.center.x, ret.center.y + [self cameraRowHeight]);
    }

    return ret;
}


- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    if (!self.collectionView.numberOfSections) {
        return @[];
    }

    NSMutableArray* attrs = [NSMutableArray array];

    // add the camera attributes
    if ([self hasPermission]) {
        if (rect.origin.y < [self cameraRowHeight]) {
            // should show camera
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            rect.size.height -= rect.origin.y;
            rect.origin.y = 0;
        } else {
            rect.origin.y -= [self cameraRowHeight];
        }
    }

    // add the rest of the attributes
    [attrs addObjectsFromArray:[super layoutAttributesForElementsInRect:rect]];

    return attrs;
}


@end
