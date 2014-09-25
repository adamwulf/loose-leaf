//
//  MMShareOptionsView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMShareOptionsView : UIView

@property (nonatomic, readonly) BOOL shouldCloseWhenSidebarHides;

-(void) reset;

-(void) show;

-(void) hide;

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation;

@end
