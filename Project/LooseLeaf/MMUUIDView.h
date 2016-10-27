//
//  MMUUIDView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMUUIDView <NSObject>

@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) NSDictionary* propertiesDictionary; // contains center/scale/uuid, optionally rotation

@end
