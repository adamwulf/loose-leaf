//
//  MMCloudKitExportCoordinator.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMUndoablePaperView.h"
#import "MMAvatarButton.h"
#import <CloudKit/CloudKit.h>

@class MMCloudKitExportView;

@interface MMCloudKitExportCoordinator : NSObject

@property (nonatomic, strong) MMAvatarButton* avatarButton;

-(id) initWithPage:(MMUndoablePaperView*)page andRecipient:(CKRecordID*)userId withButton:(MMAvatarButton*)avatarButton forExportView:(MMCloudKitExportView*)exportView;

@end
