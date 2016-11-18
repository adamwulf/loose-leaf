//
//  MMSingleStackManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperStackView.h"


@interface MMSingleStackManager : NSObject {
    UIView* visibleStack;
    UIView* bezelStack;
    UIView* hiddenStack;

    NSOperationQueue* opQueue;
}

@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, readonly) NSString* visiblePlistPath;
@property (nonatomic, readonly) NSString* hiddenPlistPath;

- (id)initWithUUID:(NSString*)uuid visibleStack:(UIView*)_visibleStack andHiddenStack:(UIView*)_hiddenStack andBezelStack:(UIView*)_bezelStack;

- (void)saveStacksToDisk;

- (BOOL)hasStateToLoad;

- (NSDictionary*)loadFromDiskWithBounds:(CGRect)bounds;

+ (NSDictionary*)loadFromDiskForStackUUID:(NSString*)stackUUID;

+ (UIImage*)hasThumbail:(BOOL*)thumbExists forPage:(NSString*)pageUUID forStack:(NSString*)stackUUID;

@end
