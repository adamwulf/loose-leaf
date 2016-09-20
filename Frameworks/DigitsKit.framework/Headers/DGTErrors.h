//
//  DGTErrors.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
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
    DGTErrorCodeUnableToAuthenticatePin = 4,
    
    /**
     * User canceled find contacts flow.
     */
    DGTErrorCodeUserCanceledFindContacts = 5,
    
    /**
     * User did not grant Digits access to their Address Book.
     */
    DGTErrorCodeUserDeniedAddressBookAccess = 6,
    
    /**
     * Failure to read from the AddressBook. 
     * When ABAddressBookCreateWithOptions fails to return a proper AddressBook.
     */
    DGTErrorCodeFailedToReadAddressBook = 7,
    
    /**
     * Something went wrong while uploading contacts. One of the following might be happening:
     *   - Rating limiting from uploading too many contacts or attempting too often. Try again in a few hours.
     *   - The network is down. Try using another network or try again in a minute.
     *   - An unexpected server error occurred. Try again in two minutes.
     */
    DGTErrorCodeUnableToUploadContacts = 8,
    
    /**
     * Something went wrong while deleting contacts.
     */
    DGTErrorCodeUnableToDeleteContacts = 9,
    
    /**
     * Something went wrong while looking up contact matches.
     */
    DGTErrorCodeUnableToLookupContactMatches = 10,
    
    /**
     * Something went wrong while attempting to save the user's email address
     */
    DGTErrorCodeUnableToCreateEmailAddress = 11

};
