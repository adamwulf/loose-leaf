//
//  MMNewsletterSignupForm.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMNewsletterSignupForm.h"
#import "MMRoundedButton.h"
#import "MMEmailInputField.h"
#import "MMTutorialManager.h"
#import "MMRotationManager.h"
#import "Constants.h"

@implementation MMNewsletterSignupForm{
    MMEmailInputField* emailInput;
    UIButton* noThanksButton;
    MMRoundedButton* signUpButton;
}

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        signUpButton = [[MMRoundedButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [self addSubview:signUpButton];

        noThanksButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [noThanksButton setTitle:@"No Thanks" forState:UIControlStateNormal];
        [noThanksButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [noThanksButton sizeToFit];
        [noThanksButton addTarget:self action:@selector(noThanksButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        CGRect b = noThanksButton.bounds;
        b.size.width += 20;
        b.size.height += 8;
        noThanksButton.bounds = b;
        [self addSubview:noThanksButton];

        [self didRotateToIdealOrientation:[[MMRotationManager sharedInstance] currentInterfaceOrientation] animated:NO];
        
        emailInput = [[MMEmailInputField alloc] initWithFrame:CGRectMake(0, 200, 300, 30)];
        emailInput.center = CGPointMake(self.bounds.size.width/2, 230);
        [self addSubview:emailInput];
        
        
    }
    return self;
}

#pragma mark - Actions

-(void) noThanksButtonTapped:(id)button{
    [[MMTutorialManager sharedInstance] optOutOfNewsLetter];
    [self.delegate didCompleteNewsletterStep];
}

#pragma mark - Tutorial View Protocol

-(BOOL) wantsNextButton{
    return NO;
}

-(BOOL) isBuffered{
    return NO;
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

#pragma mark - Rotation

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)orientation{
    [self didRotateToIdealOrientation:orientation animated:YES];
}

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated{
    CheckThreadMatches([NSThread isMainThread]);
    
    void(^block)() = ^{
        CGFloat widthOfButtons = signUpButton.bounds.size.width + noThanksButton.bounds.size.width + 20;
        CGFloat buttonMargin = (self.bounds.size.width - widthOfButtons) / 2;
        
        if(orientation == UIInterfaceOrientationPortrait ||
           orientation == UIInterfaceOrientationPortraitUpsideDown){
            signUpButton.center = CGPointMake(self.bounds.size.width/2, 300);
            noThanksButton.center = CGPointMake(self.bounds.size.width/2, 450);
        }else{
            signUpButton.center = CGPointMake(buttonMargin + signUpButton.bounds.size.width/2, 300);
            noThanksButton.center = CGPointMake(self.bounds.size.width - buttonMargin - noThanksButton.bounds.size.width/2, 300);
        }
    };
    
    if(animated){
        [UIView animateWithDuration:.2 animations:block];
    }else{
        block();
    }
    
}

@end
