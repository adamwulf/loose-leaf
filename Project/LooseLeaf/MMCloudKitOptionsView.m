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
#import "MMCloudKitShareListVerticalLayout.h"
#import "MMCloudKitShareListHorizontalLayout.h"
#import "Constants.h"
#import "MMRotationManager.h"
#import "UIView+Debug.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
    UICollectionView* listOfFriendsView;
    
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
        listOfFriendsView = [[UICollectionView alloc] initWithFrame:frForTable collectionViewLayout:[[MMCloudKitShareListVerticalLayout alloc] init]];
        listOfFriendsView.backgroundColor = [UIColor clearColor];
        listOfFriendsView.opaque = NO;
        listOfFriendsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [listOfFriendsView registerClass:[MMCloudKitFriendTableViewCell class] forCellWithReuseIdentifier:@"MMCloudKitFriendTableViewCell"];
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
    [listOfFriendsView setCollectionViewLayout:[self idealLayoutForOrientation:(UIInterfaceOrientation)[MMRotationManager sharedInstace].lastBestOrientation] animated:NO];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        return [((MMCloudKitLoggedInState*)currentState).friendList count] * 7;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMCloudKitFriendTableViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMCloudKitFriendTableViewCell" forIndexPath:indexPath];

    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        NSArray* friends = ((MMCloudKitLoggedInState*)currentState).friendList;
        int index = indexPath.row % [friends count];
//        if([friends count] > indexPath.row){
            [cell setUserInfo:[friends objectAtIndex:index] forIndex:indexPath.row];
//        }else{
//            [cell setUserInfo:nil];
//        }
    }else{
        [cell setUserInfo:nil forIndex:0];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"row: %d %d", indexPath.section, indexPath.section);
    
    MMCloudKitFriendTableViewCell* cell = (MMCloudKitFriendTableViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    [cell bounce];
}

#pragma mark - Rotation

-(UICollectionViewLayout*) idealLayoutForOrientation:(UIInterfaceOrientation)orientation{
    if(orientation == UIDeviceOrientationLandscapeLeft){
        return [[MMCloudKitShareListHorizontalLayout alloc] initWithFlip:YES];
    }else if(orientation == UIDeviceOrientationLandscapeRight){
        return [[MMCloudKitShareListHorizontalLayout alloc] initWithFlip:NO];
    }else if(orientation == UIDeviceOrientationPortraitUpsideDown){
        return [[MMCloudKitShareListVerticalLayout alloc] initWithFlip:YES];
    }else{
        return [[MMCloudKitShareListVerticalLayout alloc] initWithFlip:NO];
    }
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation{
    [listOfFriendsView setCollectionViewLayout:[self idealLayoutForOrientation:orientation] animated:YES];
}


@end
