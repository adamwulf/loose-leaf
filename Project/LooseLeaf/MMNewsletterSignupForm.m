//
//  MMNewsletterSignupForm.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMNewsletterSignupForm.h"

@implementation MMNewsletterSignupForm{
    UITextField* emailInput;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel* newsletter = [[UILabel alloc] initWithFrame:self.bounds];
        newsletter.textAlignment = NSTextAlignmentCenter;
        newsletter.text = @"sign up!";
        [self addSubview:newsletter];
        
        
        emailInput = [[UITextField alloc] initWithFrame:CGRectMake(300, 100, 200, 60)];
        emailInput.keyboardType = UIKeyboardTypeEmailAddress;
        emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
        emailInput.spellCheckingType = UITextSpellCheckingTypeNo;
        emailInput.enablesReturnKeyAutomatically = YES;
        emailInput.returnKeyType = UIReturnKeyDone;
        [self addSubview:emailInput];
        
        
    }
    return self;
}

-(BOOL) isBuffered{
    return YES;
}

-(BOOL) isAnimating{
    return [emailInput isFirstResponder];
}

-(void) startAnimating{
    [emailInput becomeFirstResponder];
}

-(void) pauseAnimating{
    [emailInput resignFirstResponder];
}

-(void) stopAnimating{
    [emailInput resignFirstResponder];
}

@end
