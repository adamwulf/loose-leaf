//
//  TwitterKit.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#if __has_feature(modules)
@import Accounts;
@import Foundation;
@import Social;
@import UIKit;
@import TwitterCore;
#if __has_include(<DigitsKit/DigitsKit.h>)
@import DigitsKit;
#endif
#else
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Social/Social.h>
#import <TwitterCore/TwitterCore.h>
#import <UIKit/UIKit.h>

#if __has_include(<DigitsKit/DigitsKit.h>)
#import <DigitsKit/DigitsKit.h>
#endif
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
#error "TwitterKit doesn't support iOS 6.x and lower. Please, change your minimum deployment target to iOS 7.0"
#endif

#import "Twitter.h"
#import "TWTRAPIClient.h"
#import "TWTRCardConfiguration.h"
#import "TWTRComposerViewController.h"
#import "TWTRCollectionTimelineDataSource.h"
#import "TWTRComposer.h"
#import "TWTRComposerTheme.h"
#import "TWTRListTimelineDataSource.h"
#import "TWTRLogInButton.h"
#import "TWTROAuthSigning.h"
#import "TWTRSearchTimelineDataSource.h"
#import "TWTRShareEmailViewController.h"
#import "TWTRTimelineDataSource.h"
#import "TWTRTimelineType.h"
#import "TWTRTimelineViewController.h"
#import "TWTRTweet.h"
#import "TWTRTweetTableViewCell.h"
#import "TWTRTweetView.h"
#import "TWTRTweetViewDelegate.h"
#import "TWTRUser.h"
#import "TWTRUserTimelineDataSource.h"

/**
 *  `TwitterKit` can be used as an element in the array passed to the `+[Fabric with:]`.
 */
#define TwitterKit [Twitter sharedInstance]
