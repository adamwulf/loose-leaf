//
//  TwitterKit.h
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#if __has_feature(modules)
@import Accounts;
@import CoreData;
@import Foundation;
@import Social;
@import UIKit;
#else
#import <Accounts/Accounts.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <UIKit/UIKit.h>
#endif

#import "Digits.h"
#import "Twitter.h"
#import "TWTRAPIClient.h"
#import "TWTRAPIErrorCode.h"
#import "TWTRComposer.h"
#import "TWTRConstants.h"
#import "TWTROAuthSigning.h"
#import "TWTRSession.h"
#import "TWTRShareEmailViewController.h"
#import "TWTRLogInButton.h"
#import "TWTRTweet.h"
#import "TWTRTweetTableViewCell.h"
#import "TWTRTweetView.h"
#import "TWTRTweetViewDelegate.h"
#import "TWTRUser.h"
#import "TWTROAuthSigning.h"

/**
 *  `TwitterKit` can be used as an element in the array passed to the `+[Fabric with:]`.
 */
#define TwitterKit [Twitter sharedInstance]
