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
#import "MMLoopIcon.h"
#import "Constants.h"

@implementation MMNewsletterSignupForm{
    MMEmailInputField* emailInput;
    UIButton* noThanksButton;
    MMRoundedButton* signUpButton;
    UILabel* pitchLbl;
}

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        CGFloat scale = .3;
        MMLoopIcon* loop = [[MMLoopIcon alloc] initWithFrame:CGRectMake(0, 0, 500*scale, 360*scale)];
        loop.center = CGPointMake(self.bounds.size.width/2 + 50, 105);
        [self addSubview:loop];
        
        NSLog (@"Font families: %@", [UIFont familyNames]);
        
        UILabel* stay = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        stay.center = CGPointMake(self.bounds.size.width/2 - 45, 80);
        stay.text = @"Stay";
        stay.font = [UIFont fontWithName:@"Lato-Bold" size:36];
        [self addSubview:stay];
        
        UILabel* inLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        inLbl.center = CGPointMake(self.bounds.size.width/2 - 45, 110);
        inLbl.text = @"in the";
        inLbl.font = [UIFont fontWithName:@"Lato-Semibold" size:20];
        [self addSubview:inLbl];
        
        pitchLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 460, 40)];
        pitchLbl.text = @"Tips, features, and offers to get the most out of Loose Leaf.";
        pitchLbl.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        pitchLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:pitchLbl];
        

        // form
        emailInput = [[MMEmailInputField alloc] initWithFrame:CGRectMake(0, 200, 300, 30)];
        [self addSubview:emailInput];
        
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
            emailInput.center = CGPointMake(self.bounds.size.width/2, 250);
            signUpButton.center = CGPointMake(self.bounds.size.width/2, 320);
            noThanksButton.center = CGPointMake(self.bounds.size.width/2, 480);
            pitchLbl.center = CGPointMake(self.bounds.size.width/2, 195);
        }else{
            emailInput.center = CGPointMake(self.bounds.size.width/2, 220);
            signUpButton.center = CGPointMake(buttonMargin + signUpButton.bounds.size.width/2, 300);
            noThanksButton.center = CGPointMake(self.bounds.size.width - buttonMargin - noThanksButton.bounds.size.width/2, 300);
            pitchLbl.center = CGPointMake(self.bounds.size.width/2, 180);
        }
    };
    
    if(animated){
        [UIView animateWithDuration:.2 animations:block];
    }else{
        block();
    }
    
}

@end
