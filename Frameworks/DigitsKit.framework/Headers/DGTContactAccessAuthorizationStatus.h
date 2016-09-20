//
//  DGTContactAccessAuthorizationStatus.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

/**
 *  Status codes for how the user has responded to a prompt to access their Address Book.
 */
typedef NS_ENUM(NSInteger, DGTContactAccessAuthorizationStatus) {
    
    /**
     *  User has neither denied nor granted access to their Address Book. They will be prompted for permission to their Address Book when requested.
     */
    DGTContactAccessAuthorizationStatusPending = 0,
    
    /**
     *  User denied access to their Address Book. They will have manually go into privacy settings and grant access to the app.
     */
    DGTContactAccessAuthorizationStatusDenied = 1,
    
    /**
     *  User granted access to their Address Book.
     */
    DGTContactAccessAuthorizationStatusAccepted = 2
};
