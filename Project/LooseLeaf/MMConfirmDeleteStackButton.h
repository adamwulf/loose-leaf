//
//  MMConfirmDeleteStackButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMConfirmDeleteStackButtonDelegate.h"


@interface MMConfirmDeleteStackButton : UIView

@property (nonatomic, weak) NSObject<MMConfirmDeleteStackButtonDelegate>* delegate;

@end
