//
//  TWTRAuthSession.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Encapsulates the authorization details of an OAuth Session.
 */
@protocol TWTRAuthSession <NSObject>

@property (nonatomic, readonly, copy) NSString *authToken;
@property (nonatomic, readonly, copy) NSString *authTokenSecret;

@end
