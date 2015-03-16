//
//  DGTContacts.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGTContactAccessAuthorizationStatus.h"

@class DGTAppearance;
@class DGTContactsUploadResult;
@class DGTSession;

/**
 *  Block type called after the Digits upload contacts flow is complete.
 *
 *  result will be nil in the case of an error.
 *  error is of the `DGTErrorDomain` domain with one of the codes in `DGTErrorCode`.
 */
typedef void (^DGTUploadContactsCompletion)(DGTContactsUploadResult *result, NSError *error);

/**
 *  Block type called after Digits lookup contacts is complete.
 *
 *  The matches object contains instances of DGTUser
 *  error is of the `DGTErrorDomain` domain with one of the codes in `DGTErrorCode`.
 */
typedef void (^DGTLookupContactsCompletion)(NSArray *matches, NSString *nextCursor, NSError *error);

/**
 *  Block type called after Digits delete all contacts is complete.
 *
 *  error is of the `DGTErrorDomain` domain with one of the codes in `DGTErrorCode`.
 */
typedef void (^DGTDeleteAllUploadedContactsCompletion)(NSError *error);

@interface DGTContacts : NSObject

/**
 *  @return The user's Address Book authorization status for this app.
 */
+ (DGTContactAccessAuthorizationStatus)contactsAccessAuthorizationStatus;

/**
 *  Returns an instance of DGTUsers that can make authenticated requests using the given user session. Subsequent calls to upload, lookup, and delete contacts will be scoped to the user for this session.
 *
 *  @return an instance of DGTUsers
 *  @param  userSession  (required) An authenticated user session, such as from `[[Digits sharedInstance] session]`.
 */
- (instancetype)initWithUserSession:(DGTSession *)userSession;

- (instancetype)init __attribute__((unavailable("Use -initWithUserSession: instead")));

/**
 *  Uploads the user's Address Book to Digits. If `+[DGTContacts contactsAccessAuthorizationStatus]` is DGTContactAccessAuthorizationStatusPending, the Address Book permission UI will be presented to the user with the standard appearance. The UI is presented as a modal off of the top-most view controller. The modal title is the application name.
 *
 *  @param completion Block called after the upload contacts flow has ended.
 */
- (void)startContactsUploadWithCompletion:(DGTUploadContactsCompletion)completion;

/**
 *  Uploads the user's Address Book to Digits. If `+[DGTContacts contactsAccessAuthorizationStatus]` is DGTContactAccessAuthorizationStatusPending,, the Address Book permission UI will be presented to the user with the standard appearance. The UI is presented as a modal off of the top-most view controller.
 *
 *  @param title      Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion Block called after the upload contacts flow has ended.
 */
- (void)startContactsUploadWithTitle:(NSString *)title completion:(DGTUploadContactsCompletion)completion;

/**
 *  Uploads the user's Address Book to Digits. If `+[DGTContacts contactsAccessAuthorizationStatus]` is DGTContactAccessAuthorizationStatusPending,, the Address Book permission UI will be presented to the user with the standard appearance.
 *
 *  @param presenterViewController    View controller used to present the modal upload contacts controller. Pass `nil` to use default top-most view controller.
 *  @param title                      Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion                 Block called after the upload contacts flow has ended.
 */
- (void)startContactsUploadWithPresenterViewController:(UIViewController *)presenterViewController title:(NSString *)title completion:(DGTUploadContactsCompletion)completion;

/**
 *  Uploads the user's Address Book to Digits. If `+[DGTContacts contactsAccessAuthorizationStatus]` is DGTContactAccessAuthorizationStatusPending,, the Address Book permission UI will be presented to the user.
 *
 *  @param appearance                 Appearance of the upload contacts flow UI views. Pass `nil` to use the default appearance.
 *  @param presenterViewController    View controller used to present the modal upload contacts controller. Pass `nil` to use default top-most view controller.
 *  @param title                      Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion                 Block called after the upload contacts flow has ended.
 */
- (void)startContactsUploadWithDigitsAppearance:(DGTAppearance *)appearance presenterViewController:(UIViewController *)presenterViewController title:(NSString *)title completion:(DGTUploadContactsCompletion)completion;

/**
 *  Initiates a request to retrieve the authenticated user's contact matches. This method will fetch a portion of matches from Digits, and will yield a cursor that can be provided in a subsequent call to offset the next set of matches.
 *
 *  @param cursor            An opaque string that can be used in a follow up call to this method to indicate an offset for the returned results. If null, return the first `count` of users.
 *  @param completion        Block called after the lookup contact matches request has finished.
 */
- (void)lookupContactMatchesWithCursor:(NSString *)cursor completion:(DGTLookupContactsCompletion)completion;

/**
 *  Initiates a request to delete all of the authenticated user's uploaded contacts.
 *
 *  @param completion        Block called after the delete all uploaded contacts request has finished.
 */
- (void)deleteAllUploadedContactsWithCompletion:(DGTDeleteAllUploadedContactsCompletion)completion;

@end
