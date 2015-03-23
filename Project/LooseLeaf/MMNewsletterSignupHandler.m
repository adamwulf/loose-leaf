//
//  MMNewsletterSignupHandler.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMNewsletterSignupHandler.h"
#import "MMReachabilityManager.h"
#import "NSString+URLEncode.h"
#import "Constants.h"

@implementation MMNewsletterSignupHandler


#pragma mark - Singleton

static MMNewsletterSignupHandler* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:kPendingEmailToSubscribe
                                                   options:NSKeyValueObservingOptionNew
                                                   context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkEmailSubscription)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkEmailSubscription)
                                                     name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

-(void) dealloc{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kPendingEmailToSubscribe];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(MMNewsletterSignupHandler*) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMNewsletterSignupHandler alloc] init];
    });
    return _instance;
}


+(void) load{
    [MMNewsletterSignupHandler sharedInstance];
}

#pragma mark - User Defaults Observer

// KVO handler
-(void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject
                       change:(NSDictionary *)aChange context:(void *)aContext{
    [self checkEmailSubscription];
}


#pragma mark - Save Email If Possible

-(void) checkEmailSubscription{
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(lowQueue, ^{
        @synchronized(self){
            NSString* emailToSubscribe = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingEmailToSubscribe];
            if(emailToSubscribe){
                NSLog(@"trying to subscribe: %@", emailToSubscribe);
                if([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
                    NSLog(@" - internet is reachable");
                    
                    NSString *post = [NSString stringWithFormat:@"email=%@",[emailToSubscribe urlEncodedString]];
                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:[NSURL URLWithString:@"https://getlooseleaf.com/member.php"]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:postData];
                    NSURLResponse* response = nil;
                    NSError* err = nil;
                    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                    if(response && !err) {
                        if([response isKindOfClass:[NSHTTPURLResponse class]]){
                            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
                            if(httpResponse.statusCode == 200){
                                NSString* dataStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                if([[dataStr lowercaseString] containsString:@"subscribed"]){
                                    NSLog(@" - Connection Successful: %@", dataStr);
                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingEmailToSubscribe];
                                }else{
                                    NSLog(@" - Invalid response: %@", dataStr);
                                }
                            }else{
                                NSLog(@" - wrong http code: %d",(int) httpResponse.statusCode);
                            }
                        }else{
                            NSLog(@" - invalid response: %@", response);
                        }
                    } else {
                        NSLog(@" - Connection could not be made: %@", err);
                    }
                }else{
                    NSLog(@" - Can't save email address, internet is unreachable");
                }
            }else{
                NSLog(@" - There is no email to subscribe to the newsletter");
            }
        }
    });
}


@end
