//
//  MMPageCloner.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/20/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMPageCloner : NSObject

@property(nonatomic, readonly) NSString* stackUUID;
@property(nonatomic, readonly) NSString* originalPageUUID;
@property(nonatomic, readonly) NSString* cloneUUID;

- (instancetype)initWithOriginalUUID:(NSString*)originalPageUUID clonedUUID:(NSString*)cloneUUID inStackUUID:(NSString*)stackUUID;

- (void)beginClone;

- (void)finishCloneAndThen:(void (^)(NSString* clonedUUID))onComplete;

- (void)abortClone;

@end
