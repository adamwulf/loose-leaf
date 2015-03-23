//
//  MMNewsletterSignupForm.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMNewsletterSignupForm.h"
#import "MMRoundedButton.h"

@implementation MMNewsletterSignupForm{
    UITextField* emailInput;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel* newsletter = [[UILabel alloc] initWithFrame:self.bounds];
        newsletter.textAlignment = NSTextAlignmentCenter;
        newsletter.text = @"sign up!";
        [self addSubview:newsletter];
        
        
        emailInput = [[UITextField alloc] initWithFrame:CGRectMake(300, 200, 200, 60)];
        emailInput.keyboardType = UIKeyboardTypeEmailAddress;
        emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
        emailInput.spellCheckingType = UITextSpellCheckingTypeNo;
        emailInput.enablesReturnKeyAutomatically = YES;
        emailInput.returnKeyType = UIReturnKeyDone;
        [self addSubview:emailInput];
        
        
        MMRoundedButton* signUpButton = [[MMRoundedButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        signUpButton.center = CGPointMake(300, 100);
        [self addSubview:signUpButton];

        UIButton* noThanksButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [noThanksButton setTitle:@"No Thanks" forState:UIControlStateNormal];
        [noThanksButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [noThanksButton sizeToFit];
        CGRect b = noThanksButton.bounds;
        b.size.width += 20;
        b.size.height += 8;
        noThanksButton.bounds = b;
        noThanksButton.center = CGPointMake(440, 100);
        [self addSubview:noThanksButton];
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
