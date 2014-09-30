//
//  MMPhotoListLayout.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPhotoAlbumListLayout : UICollectionViewLayout

-(id) initForRotation:(CGFloat)rotation;

@property (nonatomic, readonly) CGFloat rotation;

@end
