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
#import "MMCloudKitShareItem.h"
#import "Constants.h"
#import "MMRotationManager.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
    UICollectionView* listOfFriendsView;
    
    UIButton* loginButton;
}

@synthesize shareItem;

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
        listOfFriendsView.showsHorizontalScrollIndicator = NO;
        listOfFriendsView.showsVerticalScrollIndicator = NO;
        listOfFriendsView.dataSource = self;
        listOfFriendsView.delegate = self;
        [self addSubview:listOfFriendsView];

        [self cloudKitDidChangeState:[MMCloudKitManager sharedManager].currentState];
        
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
    UICollectionViewLayout* layout = [self idealLayoutForOrientation:(UIInterfaceOrientation)[MMRotationManager sharedInstance].lastBestOrientation];
    [listOfFriendsView reloadData];
    [listOfFriendsView setCollectionViewLayout:layout animated:NO];
    [self updateInterfaceBasedOniCloudStatus];
}

-(void) hide{
    NSLog(@"hiding cloudkit view");
}

#pragma mark - CloudKit UI

BOOL hasSent = NO;
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
    
//    NSLog(@"settings url: %@", UIApplicationOpenSettingsURLString);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
//    
//    [[NSThread mainThread] performBlock:^{
//        if(!hasSent){
//            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            if ([[UIApplication sharedApplication] canOpenURL:appSettings]) {
//                // make sure to use in iOS8, not iOS7
//                [[UIApplication sharedApplication] openURL:appSettings];
//            }            hasSent = YES;
//        }
//    }afterDelay:3];
    
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

-(void) willFetchMessage:(SPRMessage*)message{
    // noop
}

-(void) didFetchMessage:(SPRMessage *)message{
    // noop
}

-(void) didFailToFetchMessage:(SPRMessage *)message{
    // noop
}

#pragma mark - UICollectionViewDataSource

-(CKDiscoveredUserInfo*) userInfoForIndexPath:(NSIndexPath*)indexPath{
    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        NSArray* friends = ((MMCloudKitLoggedInState*)currentState).friendList;
        int index = indexPath.row % [friends count];
//        if([friends count] > indexPath.row){
        return [friends objectAtIndex:index];
//        }
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    MMCloudKitBaseState* currentState = [MMCloudKitManager sharedManager].currentState;
    if([currentState isKindOfClass:[MMCloudKitLoggedInState class]]){
        return [((MMCloudKitLoggedInState*)currentState).friendList count] * 11;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMCloudKitFriendTableViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMCloudKitFriendTableViewCell" forIndexPath:indexPath];
    [cell setUserInfo:[self userInfoForIndexPath:indexPath] forIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MMCloudKitFriendTableViewCell* cell = (MMCloudKitFriendTableViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    [cell bounce];
    
    [shareItem userIsAskingToShareTo:[self userInfoForIndexPath:indexPath] fromButton:[cell stealAvatarButton]];
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
