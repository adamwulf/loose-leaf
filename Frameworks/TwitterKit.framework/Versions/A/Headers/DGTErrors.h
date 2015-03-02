//
//  DGTErrors.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

/**
 *  The NSError domain of errors surfaced by Digits.
 */
FOUNDATION_EXPORT NSString * const DGTErrorDomain;

/**
 *  Error codes surfaced by the Digits kit.
 */
typedef NS_ENUM(NSInteger, DGTErrorCode) {
    /**
     *  Unspecified error.
     */
    DGTErrorCodeUnspecifiedError = 0,

    /**
     *  User canceled the Digits authentication flow.
     */
    DGTErrorCodeUserCanceledAuthentication = 1,

    /**
     * One of a few things may be happening:
     *   - The network is down.
     *   - The phone number is invalid or incomplete.
     *   - An unexpected server error occurred.
     */
    DGTErrorCodeUnableToAuthenticateNumber = 2,

    /**
     * User entered incorrect confirmation number too many times.
     */
    DGTErrorCodeUnableToConfirmNumber = 3,

    /**
     * User entered incorrect pin number too many times.
     */
    DGTErrorCodeUnableToAuthenticatePin = 4
};
