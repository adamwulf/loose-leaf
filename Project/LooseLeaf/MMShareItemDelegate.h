//
//  MMShareItemDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAvatarButton.h"
#import "MMBackgroundedPaperView.h"

@class MMAbstractShareItem;

@protocol MMShareDelegate <NSObject>

- (void)didShare:(MMAbstractShareItem*)shareItem;

- (void)mayShare:(MMAbstractShareItem*)shareItem;

- (void)wontShare:(MMAbstractShareItem*)shareItem;

@end

@protocol MMShareItemDelegate <MMShareDelegate>

- (NSURL*)urlToShare;

- (NSString*)idealFileNameForShare;

@end

@protocol MMShareSidebarDelegate <MMShareDelegate>

@property (nonatomic, assign) ExportRotation idealExportRotation;

- (void)exportVisiblePageToImage:(void (^)(NSURL* urlToImage))completionBlock;

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock;

@end

@protocol MMShareStackSidebarDelegate <MMShareDelegate>

- (NSString*)nameOfCurrentStack;

- (void)exportStackToPDF:(void (^)(NSURL* urlToPDF))completionBlock withProgress:(BOOL (^)(NSInteger pageSoFar, NSInteger totalPages))progressBlock;

@end
