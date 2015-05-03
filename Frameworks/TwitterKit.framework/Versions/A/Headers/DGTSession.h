//
//  DGTSession.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "DGTErrors.h"
#import "TWTRAuthSession.h"

/**
 *  A `DGTSession` object contains user session information after a successful Digits authentication.
 */
@interface DGTSession : NSObject <TWTRAuthSession, NSCoding>

/**
 *  The authorization token for this session. Save this token in order to make future authenticated requests to Digits APIs.
 */
@property (nonatomic, copy, readonly) NSString *authToken;

/**
 * The token secret for this session. Save this secret in order to make future authenticated requests to Digits APIs.
 */
@property (nonatomic, copy, readonly) NSString *authTokenSecret;

/**
 *  The unique ID of the authenticated user. Save this ID in order to make future requests to Digits on behalf of the authenticated user.
 */
@property (nonatomic, copy, readonly) NSString *userID;

/**
 *  The phone number provided by the user, prefixed by the country code (e.g. `+15554443322`).
 *
 *  @warning The phone number is `nil` if the user logs in using their Twitter account (for example, when they are experiencing difficulties signing in with their phone number).
 */
@property (nonatomic, copy, readonly) NSString *phoneNumber;

/**
 *  Initializes a session object with the provided session details.
 *
 *  @param authToken       The authorization token for the session.
 *  @param authTokenSecret The authorization token secret for the session.
 *  @param userID          The unique ID for the user associated with the session.
 *  @param phoneNumber     The user's phone number, e.g. `+15554443322`.
 *
 *  @return A `DGTSession` object initialized with the provided parameters.
 */
- (instancetype)initWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret userID:(NSString *)userID phoneNumber:(NSString *)phoneNumber;

@end


/**
 *  Block type called after the Digits authentication flow is complete.
 *
 *  The `session` object contains the session data if the authentication was successful. If the authentication was unsuccessful, `session` is `nil` and `error` contains an error in the domain `DGTErrorDomain` with one of the codes in `DGTErrorCode`.
 */
typedef void (^DGTAuthenticationCompletion)(DGTSession *session, NSError *error);
