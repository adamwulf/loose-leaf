//
//  MMNewsletterSignupForm.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNewsletterSignupFormDelegate.h"
#import "MMLoopView.h"


@interface MMNewsletterSignupForm : MMLoopView

@property (nonatomic, weak) NSObject<MMNewsletterSignupFormDelegate>* delegate;

- (id)initForm;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

@end
