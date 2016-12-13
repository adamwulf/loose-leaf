//
//  MMConfirmDeleteStackButtonDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMFullWidthListButton;

@protocol MMFullWidthListButtonDelegate <NSObject>

- (void)didTapLeftInFullWidthButton:(MMFullWidthListButton*)button;

- (void)didTapRightInFullWidthButton:(MMFullWidthListButton*)button;

@end
