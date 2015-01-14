//
//  MMStoreManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/13/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMStoreManager : NSObject


-(void) validateReceipt;

+(MMStoreManager*) sharedManager;


@end
