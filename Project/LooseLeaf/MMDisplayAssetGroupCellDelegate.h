//
//  MMDisplayAssetGroupCellDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/7/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMDisplayAssetGroupCell;

@protocol MMDisplayAssetGroupCellDelegate <NSObject>

- (void)deleteButtonWasTappedForCell:(MMDisplayAssetGroupCell*)cell;

@end
