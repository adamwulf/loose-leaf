//
//  DGTAppearance.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Controls the appearance of all Digits screens and UI elements.
 *
 *  The properties `backgroundColor` and `accentColor` are the only user-configurable colors. The remaining colors are derived from these two colors. The object is always initialized with the default color set.
 *
 *  Fonts in labels, input fields and buttons can be configured with custom fonts using the `headerFont`, `labelFont` and `bodyFont` properties. The disclamers and legal text shown in Digits cannot be configured.
 *
 *  @warning If you disable view controllers from styling the status bar (via `UIViewControllerBasedStatusBarAppearance = NO` in the Info.plist file), your app will have to ensure the status bar style is compatible with the Digits background color, otherwise the status bar may not be legible during the Digits screens. See Apple's documentation for `UIStatusBarStyle` for more information.
 *
 */
@interface DGTAppearance : NSObject <NSCopying>

/**
 *  The background color for all views in the Digits flow. 
 *
 *  Tip: You can use `[UIColor colorWithPatternImage:]` to have a tiled background image.
 *
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  The accent color for all views in the Digits flow. This determines the main color of elements associated with user actions (e.g. buttons).
 */
@property (nonatomic, strong) UIColor *accentColor;

/**
 *  The font for all headers in the Digits flow.
 */
@property (nonatomic, strong) UIFont *headerFont;

/**
 *  The font for all labels and buttons in the Digits flow
 */
@property (nonatomic, strong) UIFont *labelFont;

/**
 *  The font for all text in input fields, country names and other text fields.
 */
@property (nonatomic, strong) UIFont *bodyFont;

/**
 *  An image for the Login View header. 
 *  
 *  The image container has a max height of 100px and fit to maintain aspect ratio.
 */
@property (nonatomic, strong) UIImage *logoImage;

@end
