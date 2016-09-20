//
//  MMCameraCollectionViewCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMCamViewDelegate.h"
#import "MMSinglePhotoCollectionViewCellDelegate.h"


@interface MMCameraCollectionViewCell : UICollectionViewCell <MMCamViewDelegate>

@property (nonatomic, weak) NSObject<MMSinglePhotoCollectionViewCellDelegate>* delegate;

- (void)updatePhotoRotation:(BOOL)animated;

@end
