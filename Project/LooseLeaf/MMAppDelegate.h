//
//  MMAppDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMLooseLeafViewController, MMPresentationWindow;


@interface MMAppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly) BOOL isActive;
@property (strong, nonatomic) UIWindow* window;

@property (nonatomic, readonly) MMPresentationWindow* presentationWindow;

@property (strong, nonatomic) MMLooseLeafViewController* viewController;


+ (NSString*)email;
+ (void)setEmail:(NSString*)email;

@end
