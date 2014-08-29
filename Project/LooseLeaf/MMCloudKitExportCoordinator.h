//
//  MMCloudKitExportCoordinator.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMExportablePaperView.h"
#import "MMAvatarButton.h"
#import <CloudKit/CloudKit.h>

@class MMCloudKitExportView;

@interface MMCloudKitExportCoordinator : NSObject

@property (nonatomic, strong) MMAvatarButton* avatarButton;
@property (readonly) MMExportablePaperView* page;

-(id) initWithPage:(MMUndoablePaperView*)page andRecipient:(CKRecordID*)userId withButton:(MMAvatarButton*)avatarButton forExportView:(MMCloudKitExportView*)exportView;

-(void) begin;
-(void) zipGenerationIsCompleteAt:(NSString*)pathToZipFile;
-(void) zipGenerationFailed;
-(void) zipGenerationIsPercentComplete:(CGFloat)complete;

@end
