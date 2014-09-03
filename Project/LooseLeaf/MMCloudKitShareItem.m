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
#import "MMCloudKitManager.h"


@implementation MMCloudKitShareItem{
    MMCloudKitButton* button;
    MMCloudKitOptionsView* sharingOptionsView;
    NSDateFormatter *dateFormatter;
}

@synthesize delegate;
@synthesize isShowingOptionsView;

-(id) init{
    if(self = [super init]){
        button = [[MMCloudKitButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];        
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

-(void) setIsShowingOptionsView:(BOOL)_isShowingOptionsView{
    isShowingOptionsView = _isShowingOptionsView;
    button.selected = isShowingOptionsView;
    [button setNeedsDisplay];
    if(isShowingOptionsView){
        [sharingOptionsView show];
    }else{
        [sharingOptionsView hide];
    }
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    if(!isShowingOptionsView){
        [delegate mayShare:self];
        // if a popover controller is dismissed, it
        // adds the dismissal to the main queue async
        // so we need to add our next steps /after that/
        // so we need to dispatch async too
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"should update cloudkit options view");
        });
    }
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
    // only show CloudKit if it exists
    return [MMCloudKitManager isCloudKitAvailable];
}

#pragma mark - Options Menu

// will dispaly buttons to open in any other app
-(MMShareOptionsView*) optionsView{
    return sharingOptionsView;
}

-(void) userIsAskingToShareTo:(CKDiscoveredUserInfo*)userInfo fromButton:(MMAvatarButton*)avatarButton{
    [self.delegate didShare:self toUser:userInfo.userRecordID fromButton:avatarButton];
}

#pragma mark - MMShareViewDelegate

-(void) itemWasTappedInShareView{
    [[NSThread mainThread] performBlock:^{
        [delegate mayShare:self];
        [delegate didShare:self];
    }afterDelay:.3];
}

#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState *)currentState{
    [sharingOptionsView cloudKitDidChangeState:currentState];
}

-(void) didRecieveMessageFrom:(CKRecordID*)senderID withFirstName:(NSString*)firstName andLastName:(NSString*)lastName forZipFile:(NSString*)pathToZip{
    // noop
}

-(void) didFailToFetchMessage:(CKRecordID*)messageID withProperties:(NSDictionary*)properties{
    // noop
}


@end
