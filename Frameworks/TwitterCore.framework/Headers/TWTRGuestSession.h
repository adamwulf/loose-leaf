//
//  TWTRGuestSession.h
//  TwitterKit
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWTRAuthSession.h"

@class TWTRGuestSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Completion block called when guest login succeeds or fails.
 *
 *  @param guestSession A `TWTRGuestSession` containing the OAuth tokens or nil.
 *  @param error Error that will be non nil if the authentication request failed.
 */
typedef void (^TWTRGuestLogInCompletion)(TWTRGuestSession * __twtr_nullable guestSession, NSError * __twtr_nullable error);

/**
 *  `TWTRGuestSession` represents a guest session authenticated with the Twitter API. See `TWTRSession` for user sessions.
 */
@interface TWTRGuestSession : NSObject <TWTRBaseSession>

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
 *  @param sessionDictionary (required) The dictionary received after successfull authentication from Twitter guest-only authentication.
 */
- (instancetype)initWithSessionDictionary:(NSDictionary *)sessionDictionary;

/**
 *  Returns a `TWTRGuestSession` object
 *
 *  @param accessToken the access token
 *  @param guestToken the guest access token
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken guestToken:(twtr_nullable NSString *)guestToken NS_DESIGNATED_INITIALIZER;

/**
 *  Unavailable. Use `-initWithSessionDictionary:` instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithSessionDictionary: or initWithAccessToken:guestToken: instead.")));

@end

NS_ASSUME_NONNULL_END
