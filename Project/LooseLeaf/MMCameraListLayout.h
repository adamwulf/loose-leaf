//
//  MMCameraListLayout.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/7/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPhotosListLayout.h"

@interface MMCameraListLayout : MMPhotosListLayout

-(id) init NS_UNAVAILABLE;

-(id) initForRotation:(CGFloat)rotation;

@property (nonatomic, readonly) CGFloat rotation;

@end
