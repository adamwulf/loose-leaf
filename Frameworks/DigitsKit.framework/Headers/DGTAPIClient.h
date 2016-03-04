//
//  DGTAPIClient.h
//  DigitsKit
//
//  Copyright © 2015 Twitter Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGTSession.h"

@class DGTDeviceRegisterResponse;
@class DGTLogInAuthResponse;
@class DGTPhoneNumber;
@class DGTAuthenticationConfiguration;
@protocol DGTAPIAuthenticationDelegate;
@protocol DGTAPIChallengeDelegate;

@interface DGTAPIClient : NSObject

/**
 *  Returns an API Client capable of authenticating a Digits user programatically.
 *
 */
- (instancetype)init;

/**
 *
 *  Starts the authentication flow using a predetermined phone number.
 *
 *  @param configuration     Options to configure the Digits experience. The phoneNumber should be a string containing only numbers, and prefixed with an optional '+' character if the number includes a country dial code. Examples: '+15555555555' (USA, 5555555555), '+525555555555' (Mexico, 5555555555)
 *  @param authDelegate      Delegate will receive a new Challenge view controller once the authentication flow has started. The delegate is required to push or present it to continue the auth flow.
 *  @param completion        Block called after the authentication flow has ended.
 */
-(void)authenticateWithConfiguration:(DGTAuthenticationConfiguration *)configuration
                            delegate:(id<DGTAPIAuthenticationDelegate>)authDelegate
                          completion:(DGTAuthenticationCompletion)completionBlock;

@end

@protocol DGTAPIAuthenticationDelegate <NSObject>

@required

/**
 * The challenge code has been sent the phone number, the next step is for this delegate is to show the challenge view controller.
 *
 * @param challengeViewController   Challenge view controller to create or log the user in. It can be nil if there was an error.
 * @param error                     Contains an error in the domain `DGTErrorDomain` with one of the codes in `DGTErrorCode`.
 */
-(void)challengeViewController:(UIViewController<DGTAPIChallengeDelegate> *)challengeViewController error:(NSError *)error;


@optional

/**
 * Instantiate a new Challenge view controller for new users signing up for Digits
 */
- (UIViewController<DGTAPIChallengeDelegate> *)signUpViewControllerWithDeviceRegisterResponse:(DGTDeviceRegisterResponse *)deviceRegisterResponse;

/**
 * Instantiate a new Challenge view controller for existing users logging into Digits
 */
- (UIViewController<DGTAPIChallengeDelegate> *)logInViewControllerWithLogInResponse:(DGTLogInAuthResponse *)logInResponse;

@end