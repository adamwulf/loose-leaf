//
//  MMConfirmDeleteStackButtonDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMConfirmDeleteStackButtonDelegate <NSObject>

- (void)didConfirmToDeleteStack;

- (void)didCancelDeletingStack;

@end
