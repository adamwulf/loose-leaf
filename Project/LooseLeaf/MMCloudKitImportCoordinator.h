//
//  MMCloudKitImportCoordinator.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCloudKitManager.h"
#import "MMAvatarButton.h"

@class MMCloudKitImportExportView;

@interface MMCloudKitImportCoordinator : NSObject<NSCoding>

@property (nonatomic, strong) MMAvatarButton* avatarButton;
@property (readonly) NSString* uuidOfIncomingPage;
@property (readonly) BOOL isReady;
@property (nonatomic, strong) MMCloudKitImportExportView* importExportView;

-(id) initWithImport:(SPRMessage*)importMessage forImportExportView:(MMCloudKitImportExportView*)_importExportView;

-(void) begin;

-(BOOL) matchesMessage:(SPRMessage*)message;

@end
