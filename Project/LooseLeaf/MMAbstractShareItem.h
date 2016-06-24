//
//  MMAbstractShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareOptionsView.h"
#import "MMSidebarButton.h"
#import "MMShareItemDelegate.h"

@interface MMAbstractShareItem : NSObject

@property (weak, nullable) NSObject<MMShareItemDelegate>* delegate;
@property (nonatomic) BOOL isShowingOptionsView;
@property (nullable, readonly) MMShareOptionsView* optionsView;

-(MMSidebarButton * __nonnull) button;

-(BOOL) isAtAllPossible;

-(void) willShow;

-(void) didHide;

-(void) animateCompletionText:(NSString* __nonnull)linkText withImage:(UIImage* __nonnull)icon;

@end
