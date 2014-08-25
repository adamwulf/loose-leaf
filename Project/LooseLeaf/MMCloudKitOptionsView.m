//
//  MMCloudKitOptionsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOptionsView.h"
#import "MMCloudKitDeclinedPermissionState.h"
#import "MMCloudKitWaitingForLoginState.h"
#import "Constants.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
    
    UIButton* loginButton;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CGRect lblFr = self.bounds;
        lblFr.origin.y = kWidthOfSidebarButtonBuffer;
        
        cloudKitLabel = [[UILabel alloc] initWithFrame:lblFr];
        cloudKitLabel.backgroundColor = [UIColor clearColor];
        cloudKitLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cloudKitLabel.text = @"cloudkit!";
        cloudKitLabel.numberOfLines = 0;
        [self addSubview:cloudKitLabel];
        
        
        loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFr = lblFr;
        buttonFr.origin.y = lblFr.origin.y + lblFr.size.height + kWidthOfSidebarButtonBuffer;
        loginButton.frame = buttonFr;
        [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [loginButton sizeToFit];
        [self addSubview:loginButton];
        
        [MMCloudKitManager sharedManager].delegate = self;
        
        [self updateInterfaceBasedOniCloudStatus];
    }
    return self;
}

-(void) loginButtonPressed{
    [[MMCloudKitManager sharedManager] userRequestedToLogin];
}

#pragma mark - MMShareOptionsView

-(void) show{
    [super show];
    [self updateInterfaceBasedOniCloudStatus];
}

#pragma mark - CloudKit UI

-(void) updateInterfaceBasedOniCloudStatus{
    NSString* cloudKitInfo = [[MMCloudKitManager sharedManager] description];
    
    cloudKitLabel.text = cloudKitInfo;
    [cloudKitLabel sizeToFit];
    
    CGRect lblFr = cloudKitLabel.frame;
    lblFr.origin.y = kWidthOfSidebarButtonBuffer;
    lblFr.size.width = self.bounds.size.width;
    cloudKitLabel.frame = lblFr;
    
    CGRect buttonFr = lblFr;
    buttonFr.origin.y = lblFr.origin.y + lblFr.size.height + kWidthOfSidebarButtonBuffer;
    loginButton.frame = buttonFr;
    [loginButton sizeToFit];
    
    if(loginButton.hidden){
        CGRect fr = self.frame;
        fr.size.height = cloudKitLabel.bounds.size.height + cloudKitLabel.frame.origin.y;
        self.frame = fr;
    }else{
        CGRect fr = self.frame;
        fr.size.height = loginButton.bounds.size.height + loginButton.frame.origin.y;
        self.frame = fr;
    }
}

#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState *)currentState{
    if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        loginButton.hidden = NO;
    }else{
        loginButton.hidden = YES;
    }
    [self updateInterfaceBasedOniCloudStatus];
}

@end
