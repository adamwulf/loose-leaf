//
//  SLAppDelegate.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLPaperStackViewController;

@interface SLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SLPaperStackViewController *viewController;

@end
