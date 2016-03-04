//
//  TWTRAuthSession.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The base session which all sessions must conform to.
 */
@protocol TWTRBaseSession <NSObject, NSCoding>
@end

/**
 *  Encapsulates the authorization details of an OAuth Session.
 */
@protocol TWTRAuthSession <TWTRBaseSession>

@property (nonatomic, readonly, copy) NSString *authToken;
@property (nonatomic, readonly, copy) NSString *authTokenSecret;
@property (nonatomic, readonly, copy) NSString *userID;

@end
