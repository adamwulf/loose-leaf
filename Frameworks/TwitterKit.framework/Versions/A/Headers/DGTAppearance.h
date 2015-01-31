//
//  DGTAppearance.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Controls the appearance of all Digits screens and UI elements.
 *
 *  The properties `backgroundColor` and `accentColor` are the only user-configurable colors. The remaining colors are derived from these two colors. The object is always initialized with the default color set.
 *
 *  @warning If you disable view controllers from styling the status bar (via `UIViewControllerBasedStatusBarAppearance = NO` in the Info.plist file), your app will have to ensure the status bar style is compatible with the Digits background color, otherwise the status bar may not be legible during the Digits screens. See Apple's documentation for `UIStatusBarStyle` for more information.
 *
 */
@interface DGTAppearance : NSObject <NSCopying>

/**
 *  The background color for all views in the Digits flow.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  The accent color for all views in the Digits flow. This determines the main color of elements associated with user actions (e.g. buttons).
 */
@property (nonatomic, strong) UIColor *accentColor;

@end
