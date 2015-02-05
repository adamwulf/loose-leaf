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

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable) {
        button.greyscale = YES;
    }else{
        button.greyscale = NO;
    }
    [button setNeedsDisplay];
}

#pragma mark - Imgur

-(void) animateLinkTo:(NSString*) linkURL{
    // don't animate the link, we'll send it to pinterest
    [pinterest createPinWithImageURL:[NSURL URLWithString:linkURL]
                           sourceURL:[NSURL URLWithString:@"http://getlooseleaf.com"]
                         description:@"Made with @getlooseleaf"];

}


#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
