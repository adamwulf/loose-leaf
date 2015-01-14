//
//  MMStoreManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/13/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMStoreManager.h"
#import "RMStore.h"
#import "RMAppReceipt.h"

@implementation MMStoreManager

static MMStoreManager* _instance = nil;

+(MMStoreManager*) sharedManager{
    if(!_instance){
        _instance = [[MMStoreManager alloc] init];
    }
    return _instance;
}


-(void) validateReceipt{
    // Apple recommends to refresh the receipt if validation fails on iOS
    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        NSLog(@"receipt: %@", receipt);
    } failure:^(NSError *error) {
        NSLog(@"err: %@", error);
    }];

}

@end
