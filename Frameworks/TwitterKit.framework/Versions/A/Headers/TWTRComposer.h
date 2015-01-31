//
//  TWTRComposer.h
//  TwitterKit
//
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Possible values for the <i>result</i> parameter of the completionHandler property.
 */
typedef NS_ENUM(NSInteger, TWTRComposerResult) {
    /**
     *  The composer is dismissed without sending the Tweet (i.e. the user selects Cancel, or the account is unavailable).
     */
    TWTRComposerResultCancelled,

    /**
     *  The composer is dismissed and the message is being sent in the background, after the user selects Done.
     */
    TWTRComposerResultDone
};

/**
 *  Completion block called when the user finishes composing a Tweet.
 */
typedef void (^TWTRComposerCompletion)(TWTRComposerResult result);

/**
 *  The TWTRComposer class presents a view to the user to compose a Tweet.
 */
@interface TWTRComposer : NSObject

/**
 *  Sets the initial text for the Tweet composition prior to showing it.
 *
 *  @param text The text to tweet.
 *
 *  @return This will return NO if the receiver has already been presented (and therefore cannot be changed).
 */
- (BOOL)setText:(NSString *)text;

/**
 *  Sets an image attachment.
 *
 *  @param image The image to attach.
 *
 *  @return This will return NO if the receiver has already been presented (and therefore cannot be changed).
 */
- (BOOL)setImage:(UIImage *)image;

/**
 *  Adds a URL to the contents of the Tweet message.
 *
 *  @param url The URL.
 *
 *  @return This will return NO if the receiver has already been presented (and therefore cannot be changed).
 */
- (BOOL)setURL:(NSURL *)url;

/**
 *  Presents the composer, with an optional completion handler.
 *
 *  @param completion The completion handler, which has a single parameter indicating whether the user finished or cancelled the Tweet composition.
 */
- (void)showWithCompletion:(TWTRComposerCompletion)completion;

@end
