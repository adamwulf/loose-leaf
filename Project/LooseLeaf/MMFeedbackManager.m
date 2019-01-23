//
//  MMFeedbackManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/18/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackManager.h"
#import "Mixpanel.h"
#import "MMReachabilityManager.h"
#import "NSString+URLEncode.h"
#import "NSArray+Extras.h"
#import "Constants.h"

#define kFeedbackDefaultsKey @"kFeedbackDefaultsKey"


@implementation MMFeedbackManager {
    NSLock* _lock;
}

#pragma mark - Singleton

static MMFeedbackManager* _instance = nil;

- (id)init {
    if (_instance)
        return _instance;
    if ((self = [super init])) {
        _lock = [[NSLock alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(attemptToSendFeedback)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(attemptToSendFeedback)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MMFeedbackManager sharedInstance] attemptToSendFeedback];
    });
}

+ (MMFeedbackManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMFeedbackManager alloc] init];
    });
    return _instance;
}

- (void)sendFeedback:(NSString*)feedback {
    [self sendFeedback:feedback fromEmail:nil];
}

- (void)sendFeedback:(NSString*)feedback fromEmail:(NSString*)email {
    if (!feedback) {
        return;
    }

    @synchronized([self class]) {
        NSArray* existingFeedback = [[NSUserDefaults standardUserDefaults] arrayForKey:kFeedbackDefaultsKey] ?: @[];

        if (email) {
            existingFeedback = [existingFeedback arrayByAddingObject:@[feedback, email]];
        } else {
            existingFeedback = [existingFeedback arrayByAddingObject:@[feedback]];
        }

        [[NSUserDefaults standardUserDefaults] setObject:existingFeedback forKey:kFeedbackDefaultsKey];
    }

    [self attemptToSendFeedback];
}


#pragma mark - Save Email If Possible

- (void)attemptToSendFeedback {
    NSArray* existingFeedback;
    @synchronized([self class]) {
        existingFeedback = [[NSUserDefaults standardUserDefaults] arrayForKey:kFeedbackDefaultsKey] ?: @[];
    }

    if ([existingFeedback count]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_lock lock];

            NSArray<NSString*>* feedbackAndEmail = [existingFeedback firstObject];
            if ([feedbackAndEmail count]) {
                NSString* feedbackToSend = [feedbackAndEmail firstObject];
                NSString* email = [feedbackAndEmail count] == 2 ? [feedbackAndEmail objectAtIndex:1] : nil;

                DebugLog(@"trying to send feedback: %@", feedbackToSend);

                if ([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable) {
                    DebugLog(@" - internet is reachable");

                    NSString* post;

                    if (email) {
                        post = [NSString stringWithFormat:@"feedback=%@&email=%@", [feedbackToSend urlEncodedString], [email urlEncodedString]];
                    } else {
                        post = [NSString stringWithFormat:@"feedback=%@", [feedbackToSend urlEncodedString]];
                    }

                    NSData* postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    NSString* postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
                    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
                    [request setURL:[NSURL URLWithString:@"https://getlooseleaf.com/feedback.php"]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:postData];

                    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* _Nullable responseData, NSURLResponse* _Nullable response, NSError* _Nullable err) {
                        if (response && !err) {
                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                if (httpResponse.statusCode == 200) {
                                    NSString* dataStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                    if ([[dataStr lowercaseString] containsString:@"sent"]) {
                                        DebugLog(@" - Connection Successful: %@", dataStr);

                                        @synchronized([self class]) {
                                            NSArray* existingFeedback = [[NSUserDefaults standardUserDefaults] arrayForKey:kFeedbackDefaultsKey] ?: @[];

                                            if ([existingFeedback count]) {
                                                existingFeedback = [existingFeedback arrayByRemovingFirstObject];
                                            }

                                            [[NSUserDefaults standardUserDefaults] setObject:existingFeedback forKey:kFeedbackDefaultsKey];
                                        }
                                    } else {
                                        DebugLog(@" - Invalid response: %@", dataStr);
                                    }
                                } else {
                                    DebugLog(@" - wrong http code: %d", (int)httpResponse.statusCode);
                                }
                            } else {
                                DebugLog(@" - invalid response: %@", response);
                            }
                        } else {
                            DebugLog(@" - Connection could not be made: %@", err);
                        }
                    }];

                    [task resume];
                } else {
                    DebugLog(@" - Can't send feedback email, internet is unreachable");
                }
            } else {
                DebugLog(@" - There is no feedback to send");
            }
            [[Mixpanel sharedInstance] flush];

            [_lock unlock];
        });
    }
}

@end
