//
//  DGTOAuthSigning.h
//  DigitsKit
//
//  Copyright (c) 2015 Twitter Inc. All rights reserved.
//

#import <TwitterCore/TWTRCoreOAuthSigning.h>

@class TWTRAuthConfig;
@class DGTSession;

@interface DGTOAuthSigning : NSObject <TWTRCoreOAuthSigning>

/**
 *  @name Initialization
 */

/**
 *  Instantiate a `DGTOAuthSigning` object with the parameters it needs to generate the OAuth signatures.
 *
 *  @param authConfig       (required) Encapsulates credentials required to authenticate a Digits application.
 *  @param authSession      (required) Encapsulated credentials associated with a user session.
 *
 *  @return An initialized `DGTOAuthSigning` object or nil if any of the parameters are missing.
 *
 *  @see TWTRAuthConfig
 *  @see DGTSession
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig authSession:(DGTSession *)authSession NS_DESIGNATED_INITIALIZER;

/**
 *  Unavailable. Use `-initWithAuthConfig:authSession:` instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithAuthConfig:authSession: instead.")));

/**
 *  This method provides you with the OAuth signature, as well as the formed URL with the query string, to send a request to `/sdk/account`.
 *
 *  @param params           (optional) Extra custom params to be added to the Request URL. These parameters will be part of the signature which authenticity is validated by the Digits' API. These extra parameters help as a Nonce between the client's session but they are ignored by the Digits' API. The params in the Request URL can be parsed and used by your server to validate that this header is not being reused by another one of your sessions.
 *
 *  @return A dictionary with the fully formed Request URL under `TWTROAuthEchoRequestURLStringKey` (`NSString`), and the `Authorization` header in `TWTROAuthEchoAuthorizationHeaderKey` (`NSString`), to be used to sign the request.
 *
 *  @see More information about OAuth Echo: https://dev.twitter.com/oauth/echo
 *  @see More information about Verify Credentials: https://dev.twitter.com/twitter-kit/ios/oauth-echo
 */
- (NSDictionary *)OAuthEchoHeadersToVerifyCredentialsWithParams:(NSDictionary *)params;

@end
