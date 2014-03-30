//
//  ALAssetsGroup+Properties.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsGroup (Properties)

-(NSString*) name;

-(ALAssetsGroupType) type;

-(NSString*) persistentId;

-(NSURL*) url;

@end
