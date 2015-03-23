//
//  MMNewsletterSignupForm.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNewsletterSignupFormDelegate.h"

@interface MMNewsletterSignupForm : UIView

@property (nonatomic) NSObject<MMNewsletterSignupFormDelegate>* delegate;

-(BOOL) wantsNextButton;

@end
