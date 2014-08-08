//
//  MMTwitterShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTwitterShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation MMTwitterShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"twitterLarge"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
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
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
        }
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Twitter",
                                                                     kMPEventExportPropResult : strResult}];
    };

    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:tweetSheet animated:YES completion:nil];
    
    [delegate didShare];
}

- (void)dismissKeyboard{
    UITextField *tempTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    tempTextField.enabled = NO;
    [[[[UIApplication sharedApplication] keyWindow] rootViewController].view addSubview:tempTextField];
    [tempTextField becomeFirstResponder];
    [tempTextField resignFirstResponder];
    [tempTextField removeFromSuperview];
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
