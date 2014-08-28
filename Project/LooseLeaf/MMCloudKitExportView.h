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

@class MMScrapPaperStackView;

@interface MMCloudKitExportView : MMUntouchableView

@property (nonatomic, strong) MMUntouchableView* animationHelperView;
@property (nonatomic, weak) MMScrapPaperStackView* stackView;

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton;

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord;

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord;

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk;

@end
