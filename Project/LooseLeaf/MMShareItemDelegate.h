//
//  MMShareItemDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "MMAvatarButton.h"

@protocol MMShareItem;

@protocol MMShareItemDelegate <NSObject>

-(UIImage*) imageToShare;

-(void) exportToPDF:(void(^)(NSURL* urlToPDF))completionBlock;

-(NSDictionary*) cloudKitSenderInfo;

-(void) didShare:(NSObject<MMShareItem>*)shareItem;

-(void) mayShare:(NSObject<MMShareItem>*)shareItem;

-(void) wontShare:(NSObject<MMShareItem>*)shareItem;

-(void) didShare:(NSObject<MMShareItem> *)shareItem toUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)button;

@end
