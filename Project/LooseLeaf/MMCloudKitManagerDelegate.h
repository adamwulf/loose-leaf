//
//  MMCloudKitManagerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#ifndef LooseLeaf_MMCloudKitManagerDelegate_h
#define LooseLeaf_MMCloudKitManagerDelegate_h

#import <CloudKit/CloudKit.h>
#import "MMCloudKitBaseState.h"

@protocol MMCloudKitManagerDelegate <NSObject>

-(void) cloudKitDidChangeState:(MMCloudKitBaseState*)currentState;

-(void) didRecieveMessageFrom:(CKDiscoveredUserInfo*)sender forZip:(NSString*)pathToZip;

-(void) didFailToFetchMessage:(CKRecordID*)messageID withProperties:(NSDictionary*)properties;

@end


#endif
