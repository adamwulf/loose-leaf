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

@class MMAbstractShareItem;

@protocol MMShareItemDelegate <NSObject>

-(UIImage*) imageToShare;

-(void) exportToPDF:(void(^)(NSURL* urlToPDF))completionBlock;

-(NSDictionary*) cloudKitSenderInfo;

-(void) didShare:(MMAbstractShareItem*)shareItem;

-(void) mayShare:(MMAbstractShareItem*)shareItem;

-(void) wontShare:(MMAbstractShareItem*)shareItem;

-(void) didShare:(MMAbstractShareItem *)shareItem toUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)button;

@end
