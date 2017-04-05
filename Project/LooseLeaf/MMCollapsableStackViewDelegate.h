//
//  MMCollapsableStackViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMTutorialStackViewDelegate.h"

@protocol MMCollapsableStackViewDelegate <MMTutorialStackViewDelegate>

- (BOOL)isShowingCollapsedView:(NSString*)stackUUID;

- (BOOL)isAllowedToInteractWithStack:(NSString*)stackUUID;

- (void)didAskToSwitchToStack:(NSString*)stackUUID animated:(BOOL)animated viewMode:(NSString*)viewMode;

- (void)mightAskToCollapseStack:(NSString*)stackUUID;

- (void)didAskToCollapseStack:(NSString*)stackUUID animated:(BOOL)animated;

- (void)didNotAskToCollapseStack:(NSString*)stackUUID;

- (void)isPossiblyDeletingStack:(NSString*)stackUUID withPendingProbability:(CGFloat)probability;

- (void)isAskingToDeleteStack:(NSString*)stackUUID;

- (void)isNotGoingToDeleteStack:(NSString*)stackUUID;

- (void)isBeginningToEditName:(NSString*)stackUUID;

- (void)didFinishEditingName:(NSString*)stackUUID;

- (void)didAskToExportStack:(NSString*)stackUUID;

@end
