//
//  MMCloudKitExportAnimationView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUntouchableView.h"
#import "MMAvatarButton.h"
#import <CloudKit/CloudKit.h>
#import "MMCloudKitExportCoordinator.h"

@interface MMCloudKitExportView : MMUntouchableView

@property (nonatomic, strong) MMUntouchableView* animationHelperView;

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton;

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord;

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord;

@end
