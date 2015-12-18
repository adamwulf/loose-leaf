//
//  MMPrintShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/16/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPrintShareItem.h"
#import <Mixpanel/Mixpanel.h>
#import "MMReachabilityManager.h"
#import "MMProgressedImageViewButton.h"
#import "MMPresentationWindow.h"
#import "Constants.h"

@implementation MMPrintShareItem{
    MMProgressedImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMProgressedImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"print"]];
        button.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];

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
    // only allow printing if we're enabled
    if([UIPrintInteractionController isPrintingAvailable] &&
       [MMReachabilityManager sharedLocalNetwork].currentReachabilityStatus != NotReachable){
        [delegate mayShare:self];
        button.selected = YES;
        [button setNeedsDisplay];
        // if a popover controller is dismissed, it
        // adds the dismissal to the main queue async
        // so we need to add our next steps /after that/
        // so we need to dispatch async too
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
                printController.printingItem = self.delegate.imageToShare;
                
                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
                [presentationWindow makeKeyAndVisible];
                UIView* presentationView = presentationWindow.rootViewController.view;
                CGRect presentationRect = [presentationView convertRect:self.button.bounds fromView:self.button];
                [printController presentFromRect:presentationRect inView:presentationView animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
                    if(completed){
                        [self.delegate didShare:self];
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
                    }
                    NSString* strResult = completed ? @"Success" : @"Cancelled";
                    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Print",
                                                                                 kMPEventExportPropResult : strResult}];
                    button.selected = NO;
                    [button setNeedsDisplay];
                }];
            }
        });
    }else{
        [button animateToPercent:1.0 success:NO completion:nil];
    }
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([UIPrintInteractionController isPrintingAvailable] &&
       [MMReachabilityManager sharedLocalNetwork].currentReachabilityStatus != NotReachable){
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
