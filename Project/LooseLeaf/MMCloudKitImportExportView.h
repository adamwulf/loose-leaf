//
//  MMCloudKitExportAnimationView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUntouchableView.h"
#import "MMAvatarButton.h"
#import "MMCloudKitExportCoordinator.h"
#import "MMCloudKitImportCoordinator.h"
#import "MMCloudKitManagerDelegate.h"
#import <CloudKit/CloudKit.h>

@class MMScrapPaperStackView;

@interface MMCloudKitImportExportView : MMUntouchableView<MMCloudKitManagerDelegate>

@property (nonatomic, strong) MMUntouchableView* animationHelperView;
@property (nonatomic, weak) MMScrapPaperStackView* stackView;

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton;

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord;

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord;

#pragma mark - Rotation

-(void) didUpdateAccelerometerWithReading:(MMVector *)currentRawReading;

#pragma mark - Export Notifications

-(void) didFailToExportPage:(MMPaperView*)page;

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk;

-(void) isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk;

#pragma mark - Import Notifications

// notify that assets have been downloaded
-(void) importCoordinatorHasAssetsAndIsProcessing:(MMCloudKitImportCoordinator*)coordinator;

// notify that assets have been downloaded
-(void) importCoordinatorFailedPermanently:(MMCloudKitImportCoordinator*)coordinator;

// notify that assets are 100% ready for user import, show button
-(void) importCoordinatorIsReady:(MMCloudKitImportCoordinator*)coordinator;

// notify that user wants to import this page
-(void) importWasTapped:(MMCloudKitImportCoordinator*)coordinator;

@end
