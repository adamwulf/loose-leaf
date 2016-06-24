//
//  MMEmailShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEmailShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "MMPresentationWindow.h"
#import "NSURL+UTI.h"

@implementation MMEmailShareItem{
    MMImageViewButton* button;
    MFMailComposeViewController* composer;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"email"]];
        
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
        @autoreleasepool {
            composer = [[MFMailComposeViewController alloc] init];
            [composer setMailComposeDelegate:self];
            if([MFMailComposeViewController canSendMail] && composer) {
                [composer setSubject:@"Quick sketch from Loose Leaf"];
                [composer setMessageBody:@"\n\n\n\nDrawn with Loose Leaf. http://getlooseleaf.com" isHTML:NO];
                [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                
                NSURL* urlToShare = [self.delegate urlToShare];
                NSData *data = [NSData dataWithContentsOfURL:urlToShare];
                [composer addAttachmentData:data mimeType:[urlToShare mimeType] fileName:[@"LooseLeaf" stringByAppendingString:[urlToShare pathExtension]]];
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
                [presentationWindow.rootViewController presentViewController:composer animated:YES completion:^{
                    DebugLog(@"done");
                }];
            }else{
                composer = nil;
            }
            [delegate didShare:self];
        }
    });
}

-(BOOL) isAtAllPossibleForMimeType:(NSString*)mimeType{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if(![self.delegate urlToShare]){
        button.greyscale = YES;
    }else if([MFMailComposeViewController canSendMail]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
    
    if([MFMailComposeViewController canSendMail] && [MFMailComposeViewController class]) {
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusEmail to:kMPShareStatusAvailable];
    }else{
        [[[Mixpanel sharedInstance] people] set:kMPShareStatusEmail to:kMPShareStatusUnavailable];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSString* strResult;
    if(result == MFMailComposeResultCancelled){
        strResult = @"Cancelled";
    }else if(result == MFMailComposeResultFailed){
        strResult = @"Failed";
    }else if(result == MFMailComposeResultSaved){
        strResult = @"Saved";
    }else{
        strResult = @"Sent";
    }
    if(result == MFMailComposeResultSent || result == MFMailComposeResultSaved){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Email",
                                                                 kMPEventExportPropResult : strResult}];
    
    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
    [presentationWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    composer.delegate = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
