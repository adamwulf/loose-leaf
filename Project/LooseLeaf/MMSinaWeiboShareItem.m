//
//  MMSinaWeiboShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSinaWeiboShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMReachabilityManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation MMSinaWeiboShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"sinaWeibo"]];
        
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
    SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    if(fbSheet && [MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
        [fbSheet setInitialText:@"Quick sketch drawn in Loose Leaf"];
        [fbSheet addImage:self.delegate.imageToShare];
        [fbSheet addURL:[NSURL URLWithString:@"http://getlooseleaf.com"]];
        fbSheet.completionHandler = ^(SLComposeViewControllerResult result){
            NSString* strResult;
            if(result == SLComposeViewControllerResultCancelled){
                strResult = @"Cancelled";
            }else if(result == SLComposeViewControllerResultDone){
                strResult = @"Sent";
            }
            if(result == SLComposeViewControllerResultDone){
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
            }
            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"SinaWeibo",
                                                                         kMPEventExportPropResult : strResult}];
        };
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:fbSheet animated:YES completion:nil];

        [delegate didShare];
    }
}

-(BOOL) isAtAllPossible{
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo] != nil;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if(![MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable) {
        button.greyscale = YES;
    }else if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        button.greyscale = YES;
    }else{
        button.greyscale = NO;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
