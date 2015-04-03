//
//  MMSinaWeiboShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSinaWeiboShareItem.h"
#import "MMProgressedImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMReachabilityManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "MMPresentationWindow.h"

@implementation MMSinaWeiboShareItem{
    MMProgressedImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMProgressedImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"sinaWeibo"]];
        
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
            SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
            if(fbSheet && [MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
                [fbSheet setInitialText:@"Quick sketch drawn in Loose Leaf"];
                [fbSheet addImage:self.delegate.imageToShare];
                [fbSheet addURL:[NSURL URLWithString:@"http://getlooseleaf.com"]];
                fbSheet.completionHandler = ^(SLComposeViewControllerResult result){
                    NSString* strResult;
                    if(result == SLComposeViewControllerResultCancelled){
                        strResult = @"Cancelled";
                    }else{
                        strResult = @"Sent";
                    }
                    if(result == SLComposeViewControllerResultDone){
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfSocialExports by:@(1)];
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
                    }
                    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"SinaWeibo",
                                                                                 kMPEventExportPropResult : strResult}];
                    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                };
                
                [presentationWindow.rootViewController presentViewController:fbSheet animated:YES completion:nil];
                
                [delegate didShare:self];
            }else{
                [button animateToPercent:1.0 success:NO completion:nil];
            }
        }
    });
}

-(BOOL) isAtAllPossible{
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo] != nil;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable) {
        button.greyscale = YES;
    }else if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        button.greyscale = YES;
    }else{
        button.greyscale = NO;
    }
    [button setNeedsDisplay];

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusSinaWeibo to:kMPShareStatusAvailable];
    }else{
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusSinaWeibo to:kMPShareStatusUnavailable];
    }
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
