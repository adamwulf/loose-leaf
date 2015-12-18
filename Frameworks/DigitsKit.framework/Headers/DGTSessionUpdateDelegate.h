//
//  DGTSessionUpdateDelegate.h
//  DigitsKit
//
//  Copyright (c) 2015 Twitter Inc. All rights reserved.
//

@class DGTSession;

/**
 * This delegate is notified whenever there has been a change in the `Digits` session.
 */
@protocol DGTSessionUpdateDelegate <NSObject>

/**
 * Notifies when the access token and secret, or the phone number for the current user have changed.
 *
 * @param newSession  New `Digits` session containing the updated values. The new phone number in a normalized format e.g. +15555555555
 */
- (void)digitsSessionHasChanged:(DGTSession *)newSession;

/**
 * Notifies when the current session has expired. At this moment the Digits session has been logged out and you should start the Digit's login flow again to fetch a new Session.
 * Examples of this: the user has been suspended or they have deactivated their account.
 *
 * @param userID    The id for which user the session has been invalidated
 */
- (void)digitsSessionExpiredForUserID:(NSString *)userID;

@end
