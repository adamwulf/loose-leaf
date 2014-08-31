//
//  MMCloudKitImportCoordinator.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCloudKitManager.h"
#import "MMCloudKitExportView.h"

@interface MMCloudKitImportCoordinator : NSObject

-(id) initWithSender:(CKDiscoveredUserInfo*)senderInfo andButton:(MMAvatarButton*)avatarButton andZipFile:(NSString*)zipFile;

-(void) begin;

@end
