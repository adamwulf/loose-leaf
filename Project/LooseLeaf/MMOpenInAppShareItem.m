//
//  MMOpenInShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInAppShareItem.h"
#import "MMShareButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "UIColor+Shadow.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MMRotateViewController.h"
#import "MMAppDelegate.h"
#import "MMRotationManager.h"
#import "MMPresentationWindow.h"
#import "MMImageButton.h"


@implementation MMOpenInAppShareItem {
    MMShareButton* button;
    NSDateFormatter* dateFormatter;
    UIDocumentInteractionController* controller;
}

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        button = [[MMShareButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        button.arrowColor = [UIColor whiteColor];
        button.bottomBgColor = [UIColor colorWithRed:29 / 255.0 green:98 / 255.0 blue:237 / 255.0 alpha:.85];
        button.topBgColor = [UIColor colorWithRed:26 / 255.0 green:209 / 255.0 blue:250 / 255.0 alpha:.85];
        button.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];

        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];

        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmm"];
    }
    return self;
}

- (void)notification:(id)note {
    DebugLog(@"notification: %@", note);
}

- (MMSidebarButton*)button {
    return button;
}

- (void)performShareAction {
    if (!button.greyscale) {
        [delegate mayShare:self];
        // if a popover controller is dismissed, it
        // adds the dismissal to the main queue async
        // so we need to add our next steps /after that/
        // so we need to dispatch async too
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                controller = [UIDocumentInteractionController interactionControllerWithURL:[self.delegate urlToShare]];
                controller.UTI = (__bridge NSString*)(kUTTypeJPEG);
                controller.delegate = self;
                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
                UIView* presentationView = presentationWindow.rootViewController.view;
                CGRect presentationRect = [button convertRect:button.bounds toView:presentationView];
                [presentationWindow makeKeyAndVisible];
                if (![controller presentOpenInMenuFromRect:presentationRect inView:presentationView animated:YES]) {
                    [self performAirDropAction];
                }
            }
        });
    }
}


- (void)performAirDropAction {
    [self.delegate mayShare:self];
    button.selected = YES;
    [button setNeedsDisplay];

    UIActivityViewController* activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[[self.delegate urlToShare]]
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


    void (^block)(NSString*, BOOL) = ^(NSString* activityType, BOOL completed) {
        DebugLog(@"shared: %@ %d", activityType, completed);
        if (completed) {
            [self.delegate didShare:self];
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
        }
        if (!activityType)
            activityType = @"com.apple.UIKit.activity.AirDrop";
        NSString* strResult = completed ? @"Success" : @"Cancelled";
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination: activityType,
                                                                     kMPEventExportPropResult: strResult}];

        button.selected = NO;
        [button setNeedsDisplay];
    };

    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.sourceView = self.button;
        activityViewController.popoverPresentationController.sourceRect = self.button.bounds;
        activityViewController.completionWithItemsHandler = ^(NSString* activityType, BOOL completed, NSArray* returnedItems, NSError* activityError) {
            block(activityType, completed);
        };
    } else {
        [self.delegate didShare:self];
        button.selected = NO;
        [button setNeedsDisplay];
        activityViewController.completionWithItemsHandler = ^(NSString* __nullable activityType, BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError) {
            block(activityType, completed);
        };
    }

    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
    [presentationWindow makeKeyAndVisible];
    [presentationWindow.rootViewController presentViewController:activityViewController
                                                        animated:YES
                                                      completion:^{
                                                          // ...
                                                          DebugLog(@"complete");
                                                      }];
}


// called when the menu appears and our button is about to be visible
- (void)willShow {
    // noop
}


// called when our button is no longer visible
- (void)didHide {
    // noop
}

- (BOOL)isAtAllPossibleForMimeType:(NSString*)mimeType {
    return YES;
}

#pragma mark - Notification

- (void)updateButtonGreyscale {
    if (![self.delegate urlToShare]) {
        button.greyscale = YES;
    } else {
        button.greyscale = NO;
    }
    [button setNeedsDisplay];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController*)_controller {
    button.selected = YES;
    [button setNeedsDisplay];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController*)_controller {
    button.selected = NO;
    [button setNeedsDisplay];
    controller = nil;
}

- (void)documentInteractionController:(UIDocumentInteractionController*)_controller willBeginSendingToApplication:(NSString*)application {
    [delegate mayShare:self];
    [delegate didShare:self];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfOpenInExports by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{ kMPEventExportPropDestination: @"OpenIn",
                                                                  kMPEventExportPropResult: application }];
}


@end
