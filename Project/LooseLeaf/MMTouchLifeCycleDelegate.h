//
//  MMTouchLifeCycleDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MMTouchLifeCycleDelegate <NSObject>

- (void)touchesDidDie:(NSSet*)touches;

@end
