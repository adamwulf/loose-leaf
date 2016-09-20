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


@interface MMNewsletterSignupForm ()<UITextFieldDelegate>

@end

@implementation MMNewsletterSignupForm{
    MMEmailInputField* emailInput;
    UIButton* noThanksButton;
    MMRoundedButton* signUpButton;
    UILabel* pitchLbl;
    UILabel* validateInput;
    UILabel* validateInputRed;
    
    UILabel* thanksPanel;
}

@synthesize delegate;

+(BOOL) supportsURL:(NSURL*)url{
    return NO;
}

-(id) initForm{
    if(self = [super initWithTitle:nil forTutorialId:nil]){
        
        CGFloat scale = .3;
        MMLoopIcon* loop = [[MMLoopIcon alloc] initWithFrame:CGRectMake(0, 0, 500*scale, 360*scale)];
        loop.center = CGPointMake(self.bounds.size.width/2 + 50, 105);
        [self addSubview:loop];
        
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

        validateInput = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 460, 40)];
        validateInput.text = @"Please enter a valid email address.";
        validateInput.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        validateInput.textAlignment = NSTextAlignmentCenter;
        validateInput.hidden = YES;
        [self addSubview:validateInput];
        
        validateInputRed = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 460, 40)];
        validateInputRed.text = @"Please enter a valid email address.";
        validateInputRed.textColor = [UIColor redColor];
        validateInputRed.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        validateInputRed.textAlignment = NSTextAlignmentCenter;
        validateInputRed.hidden = YES;
        [self addSubview:validateInputRed];

        // form
        emailInput = [[MMEmailInputField alloc] initWithFrame:CGRectMake(0, 200, 300, 30)];
        emailInput.delegate = self;
        [self addSubview:emailInput];
        
        signUpButton = [[MMRoundedButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [signUpButton addTarget:self action:@selector(didTapSubmitButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signUpButton];

        noThanksButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [noThanksButton setTitle:@"No Thanks" forState:UIControlStateNormal];
        [noThanksButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [noThanksButton sizeToFit];
        [noThanksButton addTarget:self action:@selector(noThanksButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        CGRect b = noThanksButton.bounds;
        b.size.width += 20;
        b.size.height += 8;
        noThanksButton.bounds = b;
        [self addSubview:noThanksButton];
        
        thanksPanel = [[UILabel alloc] initWithFrame:self.bounds];
        thanksPanel.backgroundColor = [UIColor whiteColor];
        thanksPanel.textColor = [UIColor blackColor];
        thanksPanel.font = [UIFont fontWithName:@"Lato-Semibold" size:24];
        thanksPanel.textAlignment = NSTextAlignmentCenter;
        thanksPanel.alpha = 0;
        thanksPanel.text = @"Thanks!";
        [self addSubview:thanksPanel];

        [self didRotateToIdealOrientation:[[MMRotationManager sharedInstance] currentInterfaceOrientation] animated:NO];
    }
    return self;
}

#pragma mark - Actions

-(void) noThanksButtonTapped:(id)button{
    [[MMTutorialManager sharedInstance] optOutOfNewsletter];
    [self.delegate didCompleteNewsletterStep];
}

#pragma mark - MMLoopView

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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [emailInput becomeFirstResponder];
    });
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
            validateInput.center = CGPointMake(self.bounds.size.width/2, 280);
            signUpButton.center = CGPointMake(buttonMargin + signUpButton.bounds.size.width/2, 330);
            noThanksButton.center = CGPointMake(self.bounds.size.width - buttonMargin - noThanksButton.bounds.size.width/2, 330);
            pitchLbl.center = CGPointMake(self.bounds.size.width/2, 195);
        }else{
            emailInput.center = CGPointMake(self.bounds.size.width/2, 220);
            validateInput.center = CGPointMake(self.bounds.size.width/2, 250);
            signUpButton.center = CGPointMake(buttonMargin + signUpButton.bounds.size.width/2, 300);
            noThanksButton.center = CGPointMake(self.bounds.size.width - buttonMargin - noThanksButton.bounds.size.width/2, 300);
            pitchLbl.center = CGPointMake(self.bounds.size.width/2, 180);
        }
        validateInputRed.center = validateInput.center;
    };
    
    if(animated){
        [UIView animateWithDuration:.2 animations:block];
    }else{
        block();
    }
}


#pragma mark - UITextFieldDelegate

-(void) bounceEmailInput{
    [UIView animateWithDuration:1.0 animations:^{
        validateInputRed.alpha = 0;
    }];
    
    emailInput.layer.borderWidth = 1;
    emailInput.layer.borderColor = [UIColor lightGrayColor].CGColor;

    CGColorRef originalColor = emailInput.layer.borderColor;
    CGFloat originalWidth = emailInput.layer.borderWidth;
    
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    // animate from red to blue border ...
    color.fromValue = (id)[UIColor redColor].CGColor;
    color.toValue   = (__bridge id)originalColor;
    
    CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    // animate from 2pt to 4pt wide border ...
    width.fromValue = @3;
    width.toValue   = @(originalWidth);
    
    CAAnimationGroup *both = [CAAnimationGroup animation];
    // animate both as a group
    both.duration   = .75;
    both.animations = @[color, width];
    both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    both.removedOnCompletion = YES;
    
    [emailInput.layer addAnimation:both forKey:@"color and width"];
}


// email validation from:
// http://stackoverflow.com/questions/9305373/validating-the-email-address-in-uitextfield
-(NSString*) validateInput{
    NSError *error = nil;
    NSDataDetector *detector =
    [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    __block NSString* matchedEmail = nil;
    NSString* string = emailInput.text;
    [detector enumerateMatchesInString:string
                               options:kNilOptions
                                 range:NSMakeRange(0, [string length])
                            usingBlock:^(NSTextCheckingResult *result,
                                         NSMatchingFlags flags, BOOL *stop){
                                NSUInteger loc = [result.URL.absoluteString rangeOfString:@"mailto:"].location;
                                if(loc != NSNotFound){
                                    matchedEmail = [result.URL.absoluteString substringFromIndex:[@"mailto:" length]];
                                }
                            }];
    
    validateInput.hidden = (matchedEmail != nil);
    validateInputRed.hidden = (matchedEmail != nil);
    validateInputRed.alpha = 1;
    if(!matchedEmail){
        [self bounceEmailInput];
    }
    return matchedEmail;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [self didTapSubmitButton];
}

-(BOOL) didTapSubmitButton{
    NSString* validEmail = [self validateInput];
    if(validEmail){
        [[MMTutorialManager sharedInstance] signUpForNewsletter:validEmail];
        [emailInput resignFirstResponder];
        
        [UIView animateWithDuration:.3 animations:^{
            thanksPanel.alpha = 1;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate didCompleteNewsletterStep];
            });
        }];
        return YES;
    }
    return NO;
}

@end
