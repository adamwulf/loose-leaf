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
#import "UIColor+Shadow.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation MMOpenInAppShareItem{
    MMShareButton* button;
    NSDateFormatter *dateFormatter;
    UIDocumentInteractionController* controller;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMShareButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        button.arrowColor = [UIColor whiteColor];
        button.bottomBgColor = [UIColor colorWithRed:29/255.0 green:98/255.0 blue:237/255.0 alpha:.85];
        button.topBgColor = [UIColor colorWithRed:26/255.0 green:209/255.0 blue:250/255.0 alpha:.85];
        button.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmm"];
    }
    return self;
}

-(void) notification:(id)note{
    NSLog(@"notification: %@", note);
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
        NSDate *now = [[NSDate alloc] init];
        NSString *theDate = [dateFormatter stringFromDate:now];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"LooseLeaf-%@.jpg", theDate]];
        UIImage* imageToShare = self.delegate.imageToShare;
        [UIImageJPEGRepresentation(imageToShare, .9) writeToFile:filePath atomically:YES];
        NSURL* fileLocation = [NSURL fileURLWithPath:filePath];

        UIWindow* win = [[UIApplication sharedApplication] keyWindow];
        controller = [UIDocumentInteractionController interactionControllerWithURL:fileLocation];
        controller.UTI = (__bridge NSString *)(kUTTypeJPEG);
        controller.delegate = self;
        UIView* presentationView = win.rootViewController.view;
        if(![controller presentOpenInMenuFromRect:[button convertRect:button.bounds toView:presentationView] inView:presentationView animated:YES]){
            [self performAirDropAction];
        }
    });
}


-(void) performAirDropAction{
    [self.delegate mayShare:self];
    button.selected = YES;
    [button setNeedsDisplay];

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
    
    
    void(^block)(NSString *, BOOL) = ^(NSString *activityType, BOOL completed){
        NSLog(@"shared: %@ %d", activityType, completed);
        if(completed){
            [self.delegate didShare:self];
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
        }
        if(!activityType) activityType = @"com.apple.UIKit.activity.AirDrop";
        NSString* strResult = completed ? @"Success" : @"Cancelled";
        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : activityType,
                                                                     kMPEventExportPropResult : strResult}];
        
        button.selected = NO;
        [button setNeedsDisplay];
    };
    
    if([activityViewController respondsToSelector:@selector(popoverPresentationController)]){
        activityViewController.popoverPresentationController.sourceView = self.button;
        activityViewController.popoverPresentationController.sourceRect = self.button.bounds;
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            block(activityType, completed);
        };
    }else{
        [self.delegate didShare:self];
        button.selected = NO;
        [button setNeedsDisplay];
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
            block(activityType, completed);
        };
    }
    
    [win.rootViewController presentViewController:activityViewController
                                         animated:YES
                                       completion:^{
                                           // ...
                                           NSLog(@"complete");
                                       }];
}



// called when the menu appears and our button is about to be visible
-(void) willShow{
    // noop
}


// called when our button is no longer visible
-(void) didHide{
    // noop
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)_controller{
    button.selected = YES;
    [button setNeedsDisplay];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)_controller{
    button.selected = NO;
    [button setNeedsDisplay];
    controller = nil;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)_controller willBeginSendingToApplication:(NSString *)application{
    [delegate mayShare:self];
    [delegate didShare:self];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfOpenInExports by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"OpenIn",
                                                                 kMPEventExportPropResult : application}];
}


@end
