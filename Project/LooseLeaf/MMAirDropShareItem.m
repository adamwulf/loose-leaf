//
//  MMAirDropShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAirDropShareItem.h"
#import "Mixpanel.h"
#import "MMImageViewButton.h"
#import "Constants.h"

@implementation MMAirDropShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"text"]];
        
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
    [delegate mayShare:self];
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[self.delegate.imageToShare]
                                          applicationActivities:nil];
        
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                         UIActivityTypePostToTwitter,
                                                         UIActivityTypePostToWeibo,
                                                         UIActivityTypeMessage,
                                                         UIActivityTypeMail,
                                                         UIActivityTypePrint,
                                                         UIActivityTypeCopyToPasteboard,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypeAddToReadingList,
                                                         UIActivityTypePostToFlickr,
                                                         UIActivityTypePostToVimeo,
                                                         UIActivityTypePostToTencentWeibo];
        UIWindow* win = [[UIApplication sharedApplication] keyWindow];
        
        if([activityViewController respondsToSelector:@selector(popoverPresentationController)]){
            activityViewController.popoverPresentationController.sourceView = self.button;
            activityViewController.popoverPresentationController.sourceRect = self.button.bounds;
            activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
                NSLog(@"shared: %@ %d", activityType, completed);
                if(completed){
                    [self.delegate didShare:self];
                }
            };
        }else{
            [self.delegate didShare:self];
        }
        
        
//        [win.rootViewController presentModalViewController:activityViewController animated:YES];
        [win.rootViewController presentViewController:activityViewController
                                             animated:YES
                                           completion:^{
                                               // ...
                                               NSLog(@"complete");
                                           }];
    });
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    button.greyscale = NO;
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
