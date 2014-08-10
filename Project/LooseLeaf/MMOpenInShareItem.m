//
//  MMOpenInShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"

@implementation MMOpenInShareItem{
    MMImageViewButton* button;
    UIDocumentInteractionController* controller;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"photoalbum"]];
        button.greyscale = NO;
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}



-(void) performShareAction{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.png"];
    
    [UIImagePNGRepresentation(self.delegate.imageToShare) writeToFile:filePath atomically:YES];
    NSURL* fileLocation = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    
    controller = [UIDocumentInteractionController interactionControllerWithURL:fileLocation];
    
    [controller presentOpenInMenuFromRect:self.button.bounds inView:self.button animated:YES ];
    
//    controller = [[UIActivityViewController alloc] initWithActivityItems:@[fileLocation]
//                                      applicationActivities:@[]];
//    controller.excludedActivityTypes = @[UIActivityTypeAirDrop,
//                                         UIActivityTypePostToFacebook,
//                                         UIActivityTypePostToTwitter,
//                                         UIActivityTypePostToWeibo,
//                                         UIActivityTypeMessage,
//                                         UIActivityTypeMail,
//                                         UIActivityTypePrint,
//                                         UIActivityTypeCopyToPasteboard,
//                                         UIActivityTypeAssignToContact,
//                                         UIActivityTypeSaveToCameraRoll,
//                                         UIActivityTypeAddToReadingList,
//                                         UIActivityTypePostToFlickr,
//                                         UIActivityTypePostToVimeo,
//                                         UIActivityTypePostToTencentWeibo];
//
//    [self.button.window.rootViewController presentViewController:controller animated:YES completion:nil];
    
    
    

}

-(BOOL) isAtAllPossible{
    return YES;
}

@end
