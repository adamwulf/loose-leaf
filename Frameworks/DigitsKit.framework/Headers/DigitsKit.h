//
//  DigitsKit.h
//  DigitsKit
//
//  Copyright (c) 2015 Twitter Inc. All rights reserved.
//

#if __has_feature(modules)
@import AddressBook;
@import Foundation;
@import UIKit;
@import TwitterCore;
#else
#import <AddressBook/AddressBook.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <TwitterCore/TwitterCore.h>
#endif

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
#error "Digits doesn't support iOS 6.x and lower. Please, change your minimum deployment target to iOS 7.0"
#endif
#elif TARGET_OS_TV
#error This is Digits for iOS. Use the Digits for tvOS framework instead.
#elif TARGET_OS_WATCH
#error Digits doesn't support watchOS
#else
#import <Cocoa/Cocoa.h>
#endif

#import "DGTAPIClient.h"
#import "DGTAuthenticateButton.h"
#import "DGTAuthenticationConfiguration.h"
#import "DGTCompletionViewController.h"
#import "DGTContactAccessAuthorizationStatus.h"
#import "DGTContacts.h"
#import "DGTContactsUploadResult.h"
#import "DGTUser.h"
#import "DGTAppearance.h"
#import "DGTErrors.h"
#import "DGTOAuthSigning.h"
#import "DGTSession.h"
#import "DGTSessionUpdateDelegate.h"
#import "Digits.h"

/**
 *  `DigitsKit` can be used as an element in the array passed to the `+[Fabric with:]`.
 */
#define DigitsKit [Digits sharedInstance]
