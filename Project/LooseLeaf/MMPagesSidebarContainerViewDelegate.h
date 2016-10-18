//
//  MMPagesSidebarContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/18/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMTutorialStackView;

@protocol MMPagesSidebarContainerViewDelegate <MMCountableSidebarContainerViewDelegate>

- (MMTutorialStackView*)stackForUUID:(NSString*)uuid;

@end
