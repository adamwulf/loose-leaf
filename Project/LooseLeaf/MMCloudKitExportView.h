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
#import "MMCloudKitManagerDelegate.h"

@class MMScrapPaperStackView;

@interface MMCloudKitExportView : MMUntouchableView<MMCloudKitManagerDelegate>

@property (nonatomic, strong) MMUntouchableView* animationHelperView;
@property (nonatomic, weak) MMScrapPaperStackView* stackView;

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton;

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord;

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord;

#pragma mark - Export Notifications

-(void) didFailToExportPage:(MMPaperView*)page;

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk;

-(void) isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk;

@end
