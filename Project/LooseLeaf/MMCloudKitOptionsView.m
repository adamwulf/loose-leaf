//
//  MMCloudKitOptionsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOptionsView.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
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
        
        [SPRSimpleCloudKitManager sharedManager].delegate = self;
        
        [self cloudKitStatusChanged];
    }
    return self;
}


#pragma mark - SPRSimpleCloudKitManagerDelegate

-(void) cloudKitStatusChanged{
    NSString* cloudKitInfo;
    if([SPRSimpleCloudKitManager sharedManager].accountStatus == CKAccountStatusAvailable){
        cloudKitInfo = @"Available";
        if([SPRSimpleCloudKitManager sharedManager].accountRecordID){
            cloudKitInfo = [cloudKitInfo stringByAppendingFormat:@"\nrecord id: %@", [SPRSimpleCloudKitManager sharedManager].accountRecordID];
        }
        if([SPRSimpleCloudKitManager sharedManager].accountInfo){
            cloudKitInfo = [cloudKitInfo stringByAppendingFormat:@"\ninfo: %@", [SPRSimpleCloudKitManager sharedManager].accountInfo];
        }
        if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusCouldNotComplete){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: unknown"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusDenied){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: denied"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusGranted){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: granted"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusInitialState){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: initial state"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == SCKMApplicationPermissionStatusLoading){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: loading"];
        }
    }else if([SPRSimpleCloudKitManager sharedManager].accountStatus == SCKMAccountStatusLoading){
        cloudKitInfo = @"Loading";
    }else{
        cloudKitInfo = @"Not Available";
    }
    
    cloudKitLabel.text = cloudKitInfo;
    [cloudKitLabel sizeToFit];
    
    CGRect fr = cloudKitLabel.frame;
    fr.origin.y = kWidthOfSidebarButtonBuffer;
    fr.size.width = self.bounds.size.width;
    cloudKitLabel.frame = fr;

    fr = self.frame;
    fr.size.height = cloudKitLabel.bounds.size.height + cloudKitLabel.frame.origin.y;
    self.frame = fr;
}

-(void) show{
    [super show];
    [self cloudKitStatusChanged];
    [[SPRSimpleCloudKitManager sharedManager] verifyiCloudAccountStatusOnComplete:^(SCKMAccountStatus accountStatus, SCKMApplicationPermissionStatus permissionStatus, NSError *error) {
        [self cloudKitStatusChanged];
    }];
}


@end
