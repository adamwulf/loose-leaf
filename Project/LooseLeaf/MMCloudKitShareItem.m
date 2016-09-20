//
//  MMCloudKitShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitShareItem.h"
#import "MMCloudKitButton.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMCloudKitOptionsView.h"
#import "UIColor+Shadow.h"
#import <CloudKit/CloudKit.h>
#import <MessageUI/MessageUI.h>
#import "MMCloudKitManager.h"
#import "MMPresentationWindow.h"


@interface MMCloudKitShareItem (Private) <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end


@implementation MMCloudKitShareItem {
    MMCloudKitButton* button;
    MMCloudKitOptionsView* sharingOptionsView;
    NSDateFormatter* dateFormatter;
}

@synthesize delegate;
@synthesize showingOptionsView;

- (id)init {
    if (self = [super init]) {
        button = [[MMCloudKitButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"icloud-share"]];

        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];

        // arbitrary size, will be resized to fit when it's added to a sidebar
        sharingOptionsView = [[MMCloudKitOptionsView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        sharingOptionsView.shareItem = self;

        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmm"];
    }
    return self;
}

- (void)setShowingOptionsView:(BOOL)_isShowingOptionsView {
    showingOptionsView = _isShowingOptionsView;
    button.selected = showingOptionsView;
    [button setNeedsDisplay];
    if (showingOptionsView) {
        [sharingOptionsView show];
    } else {
        [sharingOptionsView hide];
    }
}

- (MMSidebarButton*)button {
    return button;
}

- (void)performShareAction {
    if (!showingOptionsView) {
        [sharingOptionsView reset];
        [delegate mayShare:self];
        // if a popover controller is dismissed, it
        // adds the dismissal to the main queue async
        // so we need to add our next steps /after that/
        // so we need to dispatch async too
        dispatch_async(dispatch_get_main_queue(), ^{
            DebugLog(@"should update cloudkit options view %@", [MMCloudKitManager sharedManager].currentState);
        });
    } else {
        [delegate wontShare:self];
    }
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
    // only show CloudKit if it exists
    return mimeType && [MMCloudKitManager isCloudKitAvailable];
}

#pragma mark - Options Menu

// will dispaly buttons to open in any other app
- (MMShareOptionsView*)optionsView {
    return sharingOptionsView;
}

- (void)userIsAskingToShareTo:(NSDictionary*)userInfo fromButton:(MMAvatarButton*)avatarButton {
    [self.delegate didShare:self toUser:[userInfo objectForKey:@"recordId"] fromButton:avatarButton];
}

- (NSDictionary*)cloudKitSenderInfo {
    return [self.delegate cloudKitSenderInfo];
}

#pragma mark - MMShareViewDelegate

- (void)itemWasTappedInShareView {
    [[NSThread mainThread] performBlock:^{
        [delegate mayShare:self];
        [delegate didShare:self];
    } afterDelay:.3];
}

#pragma mark - MMCloudKitManagerDelegate

- (void)cloudKitDidChangeState:(MMCloudKitBaseState*)currentState {
    [sharingOptionsView cloudKitDidChangeState:currentState];
}

#pragma mark - Invite

- (void)didTapInviteButton {
    if ([MFMailComposeViewController canSendMail]) {
        [self inviteWithEmail];
    } else if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
        if (composer) {
            [composer setMessageComposeDelegate:self];
            [composer setBody:@"Let's share ideas and sketches with Loose Leaf for iPad! http://getlooseleaf.com"];
            [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

            MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
            [presentationWindow.rootViewController presentViewController:composer animated:YES completion:nil];
        }
    } else {
        [self inviteWithEmail];
        // track how many users try to invite w/o any email/sms installed
        [[Mixpanel sharedInstance] track:kMPEventInvite properties:@{ kMPEventInvitePropDestination: @"None",
                                                                      kMPEventInvitePropResult: @"Failed" }];
    }
}

- (void)inviteWithEmail {
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    if (composer) {
        [composer setMailComposeDelegate:self];
        [composer setSubject:@"Let's share ideas and sketches with Loose Leaf for iPad"];
        [composer setMessageBody:@"I'm using Loose Leaf to sketch and brainstorm ideas. It makes it easy to import photos, cut and crop with scissors, and sketch and annotate. Download it now from http://getlooseleaf.com!" isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

        MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
        [presentationWindow.rootViewController presentViewController:composer animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString* strResult;
    if (result == MFMailComposeResultCancelled) {
        strResult = @"Cancelled";
    } else if (result == MFMailComposeResultFailed) {
        strResult = @"Failed";
    } else if (result == MFMailComposeResultSaved) {
        strResult = @"Saved";
    } else {
        strResult = @"Sent";
    }
    if (result == MFMailComposeResultSent || result == MFMailComposeResultSaved) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfInvites by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventInvite properties:@{ kMPEventInvitePropDestination: @"Email",
                                                                  kMPEventInvitePropResult: strResult }];

    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
    controller.delegate = nil;
    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result {
    NSString* strResult;
    if (result == MessageComposeResultCancelled) {
        strResult = @"Cancelled";
    } else if (result == MessageComposeResultFailed) {
        strResult = @"Failed";
    } else {
        strResult = @"Sent";
    }
    if (result == MessageComposeResultSent) {
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfInvites by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventInvite properties:@{ kMPEventInvitePropDestination: @"SMS",
                                                                  kMPEventInvitePropResult: strResult }];

    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
    controller.delegate = nil;
    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
