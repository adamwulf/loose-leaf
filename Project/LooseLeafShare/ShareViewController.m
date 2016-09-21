//
//  ShareViewController.m
//  LooseLeafShare
//
//  Created by Adam Wulf on 9/20/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "ShareViewController.h"


@interface ShareViewController ()

@end


@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.


    for (NSExtensionItem* item in self.extensionContext.inputItems) {
        // process the item's attachments to save stuff back to loose leaf
    }


    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray*)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
