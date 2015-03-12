//
//  DGTAuthenticateButton.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGTSession.h"

/**
 *  A button that launches the Digits authentication flow.
 */
@interface DGTAuthenticateButton : UIButton

/**
 *  Returns a pre-customized `UIButton` subclass that launches the Digits authentication flow when tapped and calls `completion` when authentication succeeds or fails.
 *
 *  Internally, this button simply calls `-[Digits authenticateWithCompletion:]`.
 *
 *  @param completion The completion to be called with a `session` object if successful. If the user cancels the authentication flow the session object is `nil`.
 *  @return An initialized `DGTAuthenticateButton`.
 */
+ (instancetype)buttonWithAuthenticationCompletion:(DGTAuthenticationCompletion)completion;

/**
 *  Sets the appearance of the button and the authentication flow. See `DGTAppearance` for details.
 *
 * @note Changing the appearance after the button has been added to the window has no effect. In order to see the effect of an appearance change, remove the button from the window and add it again.
 *
 */
@property (nonatomic, copy) DGTAppearance *digitsAppearance;

@end
