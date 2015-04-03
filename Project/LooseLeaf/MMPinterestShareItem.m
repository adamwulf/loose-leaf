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
    Pinterest* pinterest;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        pinterest = [[Pinterest alloc] initWithClientId:@"YOUR_PINTEREST_APP_ID" urlSchemeSuffix:@"looseleaf"];

        button = [[MMProgressedImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"pinterest"]];
        
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

-(BOOL) isAtAllPossible{
    return YES;
}

-(NSString*) exportDestinationName{
    return @"Pinterest";
}

-(NSString*) exportDestinationResult{
    return @"Pending";
}

-(void) performShareAction{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"pinterest://pin/"]]){
        // call the pinterest method to send the user to the store
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Share with Pinterest" message:@"The Pinterest app needs to be installed to share to Pinterest." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Get the App", nil];
        [alertView show];
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : [self exportDestinationName],
                                                                     kMPEventExportPropResult : @"Failed"}];
    }else{
        [super performShareAction];
    }
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable) {
        button.greyscale = YES;
    }else if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"pinterest://pin/"]]){
        button.greyscale = YES;
    }else{
        button.greyscale = NO;
    }
    [button setNeedsDisplay];
}

#pragma mark - Imgur

-(void) animateLinkTo:(NSString*) linkURL{
    [[NSThread mainThread] performBlock:^{
        // don't animate the link, we'll send it to pinterest instead
        [pinterest createPinWithImageURL:[NSURL URLWithString:linkURL]
                               sourceURL:[NSURL URLWithString:@"http://getlooseleaf.com"]
                             description:@"Made with @getlooseleaf"];
        [delegate didShare:self];
    } afterDelay:.3];
}


#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [pinterest createPinWithImageURL:[NSURL URLWithString:@"http://placekitten.com/g/500/400"]
                               sourceURL:[NSURL URLWithString:@"http://getlooseleaf.com"]
                             description:@"Made with @getlooseleaf"];
    }
}

@end
