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
#import "MMCloudKitLoggedInState.h"
#import "MMCloudKitFriendTableViewCell.h"
#import "Constants.h"
#import "UIView+Debug.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
    UITableView* listOfFriendsView;
    
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
        
        CGRect frForTable = self.bounds;
        frForTable.origin.y = kWidthOfSidebarButtonBuffer;
        frForTable.size.height -= kWidthOfSidebarButtonBuffer;
        listOfFriendsView = [[UITableView alloc] initWithFrame:frForTable style:UITableViewStylePlain];
        listOfFriendsView.backgroundColor = [UIColor clearColor];
        listOfFriendsView.opaque = NO;
        listOfFriendsView.separatorStyle = UITableViewCellSeparatorStyleNone;
        listOfFriendsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [listOfFriendsView registerClass:[MMCloudKitFriendTableViewCell class] forCellReuseIdentifier:@"MMCloudKitFriendTableViewCell"];
        listOfFriendsView.dataSource = self;
        listOfFriendsView.delegate = self;
        [self addSubview:listOfFriendsView];

        [MMCloudKitManager sharedManager].delegate = self;
        [self cloudKitDidChangeState:[MMCloudKitManager sharedManager].currentState];
        
        [self updateInterfaceBasedOniCloudStatus];
    }
    return self;
}

-(void) loginButtonPressed{
    MMCloudKitBaseState* currentState = [[MMCloudKitManager sharedManager] currentState];
    if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        [(MMCloudKitWaitingForLoginState*)currentState didAskToLogin];
    }
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
}

#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState *)currentState{
    if([currentState isKindOfClass:[MMCloudKitWaitingForLoginState class]]){
        loginButton.hidden = NO;
    }else{
        loginButton.hidden = YES;
    }
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        [listOfFriendsView reloadData];
        listOfFriendsView.hidden = NO;
        cloudKitLabel.hidden = YES;
    }else{
        listOfFriendsView.hidden = YES;
        cloudKitLabel.hidden = NO;
    }
    [self updateInterfaceBasedOniCloudStatus];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        return [((MMCloudKitLoggedInState*)currentState).friendList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MMCloudKitFriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MMCloudKitFriendTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;

    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        NSArray* friends = ((MMCloudKitLoggedInState*)currentState).friendList;
        if([friends count] > indexPath.row){
            [cell setUserInfo:[friends objectAtIndex:indexPath.row]];
        }else{
            [cell setUserInfo:nil];
        }
    }else{
        [cell setUserInfo:nil];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat) buttonWidth{
    CGFloat buttonWidth = self.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
    buttonWidth /= 4; // four buttons wide
    return buttonWidth;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self buttonWidth];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self buttonWidth];
}

@end
