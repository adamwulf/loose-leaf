//
//  MMNewsletterSignupForm.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMNewsletterSignupForm.h"

@implementation MMNewsletterSignupForm

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel* newsletter = [[UILabel alloc] initWithFrame:self.bounds];
        newsletter.textAlignment = NSTextAlignmentCenter;
        newsletter.text = @"sign up!";
        [self addSubview:newsletter];
    }
    return self;
}

@end
