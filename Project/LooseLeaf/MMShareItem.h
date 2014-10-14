//
//  MMShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMSidebarButton.h"
#import "MMShareOptionsView.h"
#import "MMShareItemDelegate.h"

@protocol MMShareItem <NSObject>

@property (weak) NSObject<MMShareItemDelegate>* delegate;

-(MMSidebarButton*) button;

-(BOOL) isAtAllPossible;

@optional

@property (nonatomic) BOOL isShowingOptionsView;

-(MMShareOptionsView*) optionsView;

-(void) willShow;

-(void) didHide;

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation;

@end
