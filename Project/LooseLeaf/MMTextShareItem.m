//
//  MMTextShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTextShareItem.h"
#import "Mixpanel.h"
#import "MMImageViewButton.h"
#import "Constants.h"

@implementation MMTextShareItem{
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
        MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
        [composer setMessageComposeDelegate:self];
        if([MFMessageComposeViewController canSendText]) {
            if([MFMessageComposeViewController canSendSubject]){
                [composer setSubject:@"Quick sketch from Loose Leaf"];
            }
            [composer setBody:@"\nDrawn with Loose Leaf. http://getlooseleaf.com"];
            [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSData *data = UIImagePNGRepresentation(self.delegate.imageToShare);
            [composer addAttachmentData:data typeIdentifier:@"image/png" filename:@"LooseLeaf.png"];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:composer animated:YES completion:nil];
        }
        [delegate didShare:self];
    });
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MFMessageComposeViewController canSendText]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString* strResult;
    if(result == MessageComposeResultCancelled){
        strResult = @"Cancelled";
    }else if(result == MessageComposeResultFailed){
        strResult = @"Failed";
    }else if(result == MessageComposeResultSent){
        strResult = @"Sent";
    }
    if(result == MessageComposeResultSent){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"SMS",
                                                                 kMPEventExportPropResult : strResult}];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
