//
//  MMPinterestShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/4/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPinterestShareItem.h"
#import "MMProgressedImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMReachabilityManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "MMPresentationWindow.h"
#import <Pinterest/Pinterest.h>

@implementation MMPinterestShareItem{
    MMProgressedImageViewButton* button;
    Pinterest* pinterest;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        pinterest = [[Pinterest alloc] initWithClientId:@"YOUR_PINTEREST_APP_ID" urlSchemeSuffix:@"looseleaf"];

        button = [[MMProgressedImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"twitterLarge"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:kReachabilityChangedNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    [delegate mayShare:self];
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            if(tweetSheet && [MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
                // TODO: fix twitter share when wifi enabled w/o any network
                // this hung with the modal "open" in the window, no events triggered when tryign to draw
                // even though the twitter dialog never showed. wifi was on but not connected.
                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
                [tweetSheet setInitialText:@"Quick sketch drawn in Loose Leaf @getlooseleaf"];
                [tweetSheet addImage:self.delegate.imageToShare];
                tweetSheet.completionHandler = ^(SLComposeViewControllerResult result){
                    NSString* strResult;
                    if(result == SLComposeViewControllerResultCancelled){
                        strResult = @"Cancelled";
                    }else if(result == SLComposeViewControllerResultDone){
                        strResult = @"Sent";
                    }
                    if(result == SLComposeViewControllerResultDone){
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfSocialExports by:@(1)];
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
                    }
                    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Twitter",
                                                                                 kMPEventExportPropResult : strResult}];
                    
                    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                };
                
                [presentationWindow.rootViewController presentViewController:tweetSheet animated:YES completion:^{
                    DebugLog(@"finished");
                }];
                
                [delegate didShare:self];
            }else{
                [button animateToPercent:1 success:NO completion:nil];
            }
        }
    });
}

-(BOOL) isAtAllPossible{
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] != nil;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable) {
        button.greyscale = YES;
    }else if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        button.greyscale = YES;
    }else{
        button.greyscale = NO;
    }
    [button setNeedsDisplay];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusTwitter to:kMPShareStatusAvailable];
    }else{
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusTwitter to:kMPShareStatusUnavailable];
    }
}


#pragma mark - Pinterest


- (void)pinIt:(id)sender
{
    [pinterest createPinWithImageURL:[NSURL URLWithString:@"http://placekitten.com/500/400"]
                            sourceURL:[NSURL URLWithString:@"http://placekitten.com"]
                          description:@"Pinning from Pin It Demo"];
}


#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
