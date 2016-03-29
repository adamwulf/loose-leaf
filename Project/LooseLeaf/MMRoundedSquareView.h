//
//  MMRoundedSquareView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMRoundedSquareView : UIView

@property (nonatomic, readonly) UIView* rotateableSquareView;
@property (nonatomic, readonly) UIView* maskedScrollContainer;

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

@end
