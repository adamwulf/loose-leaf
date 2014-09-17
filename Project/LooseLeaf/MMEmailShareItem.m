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

@implementation MMEmailShareItem{
    MMImageViewButton* button;
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
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setMailComposeDelegate:self];
        if([MFMailComposeViewController canSendMail]) {
            [composer setSubject:@"Quick sketch from Loose Leaf"];
            [composer setMessageBody:@"\n\n\n\nDrawn with Loose Leaf. http://getlooseleaf.com" isHTML:NO];
            [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSData *data = UIImagePNGRepresentation(self.delegate.imageToShare);
            [composer addAttachmentData:data  mimeType:@"image/png" fileName:@"LooseLeaf.png"];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:composer animated:YES completion:^{
                NSLog(@"done");
            }];
        }
        [delegate didShare:self];
    });
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MFMailComposeViewController canSendMail]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
    
    if([MFMailComposeViewController canSendMail]) {
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
    }else if(result == MFMailComposeResultSent){
        strResult = @"Sent";
    }
    if(result == MFMailComposeResultSent || result == MFMailComposeResultSaved){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Email",
                                                                 kMPEventExportPropResult : strResult}];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
