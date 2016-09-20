//
//  DGTContactsUploadResult.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGTContactsUploadResult : NSObject

/**
 *  The total number of records from the Address Book Digits attempted to upload.
 */
@property (nonatomic, readonly) NSUInteger totalContacts;

/**
 *  The number of attempted contacts that were successfully uploaded.
 */
@property (nonatomic, readonly) NSUInteger numberOfUploadedContacts;

- (instancetype)init __unavailable;

@end
