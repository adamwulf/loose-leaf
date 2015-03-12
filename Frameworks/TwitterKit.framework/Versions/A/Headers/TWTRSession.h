//
//  TWTRSession.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "TWTRAuthSession.h"

/**
 *  Authentication configuration details. Encapsulates credentials required to authenticate a Twitter application. You can obtain your credentials at https://apps.twitter.com/.
 */
@interface TWTRAuthConfig : NSObject

/**
 *  The consumer key of the Twitter application.
 */
@property (nonatomic, copy, readonly) NSString *consumerKey;
/**
 *  The consumer secret of the Twitter application.
 */
@property (nonatomic, copy, readonly) NSString *consumerSecret;

/**
 *  Returns an `TWTRAuthConfig` object initialized by copying the values from the consumer key and consumer secret.
 *
 *  @param consumerKey The consumer key.
 *  @param consumerSecret The consumer secret.
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 *  Unavailable. Use `initWithConsumerKey:consumerSecret:` instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithConsumerKey:consumerSecret: instead.")));

@end

/**
 *  TWTRSession represents a user's session authenticated with the Twitter API.
 */
@interface TWTRSession : NSObject <TWTRAuthSession>

/**
 *  The authorization token.
 */
@property (nonatomic, copy, readonly) NSString *authToken;
/**
 *  The authorization token secret.
 */
@property (nonatomic, copy, readonly) NSString *authTokenSecret;
/**
 *  The username associated with the access token.
 */
@property (nonatomic, copy, readonly) NSString *userName;
/**
 *  The user ID associated with the access token.
 */
@property (nonatomic, copy, readonly) NSString *userID;

/**
 *  Returns an `TWTRSession` object initialized by copying the values from the dictionary or nil if the dictionary is missing.
 *
 *  @param sessionDictionary The dictionary received after successfull authentication from Twitter OAuth.
 */
- (instancetype)initWithSessionDictionary:(NSDictionary *)sessionDictionary;

/**
 *  Unavailable. Use -initWithSessionDictionary: instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithSessionDictionary: instead.")));

@end

/**
 *  TWTRGuestSession represents a guest session authenticated with the Twitter API. See TWTRSession for user sessions.
 */
@interface TWTRGuestSession : NSObject

/**
 *  The bearer access token for guest auth.
 */
@property (nonatomic, copy, readonly) NSString *accessToken;

/**
 *  The guest access token.
 */
@property (nonatomic, copy, readonly) NSString *guestToken;

/**
 *  Returns an `TWTRGuestSession` object initialized by copying the values from the dictionary or nil if the dictionary is missing.
 *
 *  @param sessionDictionary The dictionary received after successfull authentication from Twitter guest-only authentication.
 */
- (instancetype)initWithSessionDictionary:(NSDictionary *)sessionDictionary;

/**
 *  Unavailable. Use -initWithSessionDictionary: instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithSessionDictionary: instead.")));

@end

/**
 *  Completion block called when user login succeeds or fails.
 *
 *  @param session Contains the OAuth tokens and minimal information associated with the logged in user or nil.
 *  @param error Error that will be non nil if the authentication request failed.
 */
typedef void (^TWTRLogInCompletion)(TWTRSession *session, NSError *error);

/**
 *  Completion block called when guest login succeeds or fails.
 *
 *  @param guestSession A TWTRGuestSession containing the OAuth tokens or nil.
 *  @param error Error that will be non nil if the authentication request failed.
 */
typedef void (^TWTRGuestLogInCompletion)(TWTRGuestSession *guestSession, NSError *error);
