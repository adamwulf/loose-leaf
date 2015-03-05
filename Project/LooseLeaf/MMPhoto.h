//
//  MMPhoto.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMDisplayAsset.h"

@interface MMPhoto : MMDisplayAsset

-(id) initWithALAsset:(ALAsset*)asset;

@end
