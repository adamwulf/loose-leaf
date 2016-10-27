//
//  MMTwitterFollow.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTwitterFollow.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>


@implementation MMTwitterFollow


- (IBAction)follow:(id)sender {
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError* error) {

        if (granted) {
            // Get the list of Twitter accounts.
            NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];

            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount* twitterAccount = [accountsArray objectAtIndex:0];

                NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
                [tempDict setValue:[self usernameToFollow] forKey:@"screen_name"];
                [tempDict setValue:@"true" forKey:@"follow"];

                SLRequest* followRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];

                [followRequest setAccount:twitterAccount];
                [followRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                    NSString* output = [NSString stringWithFormat:@"HTTP response status: %i", (int)[urlResponse statusCode]];
                    NSLog(@"%@", output);
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Update UI to show follow request failed


                            NSLog(@"failed!");


                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Update UI to show success

                            NSLog(@"ok!");

                        });
                    }
                }];
            }
        }
    }];
}

@end
