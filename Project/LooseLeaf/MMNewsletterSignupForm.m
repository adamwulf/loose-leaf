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
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Mixpanel.h"


@interface MMNewsletterSignupForm () <UITextFieldDelegate>

@end


@implementation MMNewsletterSignupForm {
    MMEmailInputField* emailInput;
    UIButton* noThanksButton;
    MMRoundedButton* signUpButton;
    UILabel* pitchLbl;
    UILabel* validateInput;
    UILabel* validateInputRed;
    UIButton* twitterFollowButton;

    UILabel* thanksPanel;

    UILabel* stayLbl;
    UILabel* inTheLbl;
    MMLoopIcon* loopImage;
}

@synthesize delegate;

+ (BOOL)supportsURL:(NSURL*)url {
    return NO;
}

- (id)initForm {
    if (self = [super initWithTitle:nil forTutorialId:nil]) {
        CGFloat scale = .3;
        loopImage = [[MMLoopIcon alloc] initWithFrame:CGRectMake(0, 0, 500 * scale, 360 * scale)];
        loopImage.center = CGPointMake(self.bounds.size.width / 2 + 50, 105);
        [self addSubview:loopImage];

        stayLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        stayLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 80);
        stayLbl.text = @"Stay";
        stayLbl.font = [UIFont fontWithName:@"Lato-Bold" size:36];
        [self addSubview:stayLbl];

        inTheLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        inTheLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 110);
        inTheLbl.text = @"in the";
        inTheLbl.font = [UIFont fontWithName:@"Lato-Semibold" size:20];
        [self addSubview:inTheLbl];

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

        twitterFollowButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [twitterFollowButton setTitle:@"Follow @getlooseleaf" forState:UIControlStateNormal];
        [twitterFollowButton sizeToFit];
        [twitterFollowButton setBounds:CGRectResizeBy([twitterFollowButton bounds], 80, 10)];
        [twitterFollowButton addTarget:self action:@selector(followOnTwitter:) forControlEvents:UIControlEventTouchUpInside];
        b = twitterFollowButton.bounds;
        b.size.width += 20;
        b.size.height += 8;
        twitterFollowButton.bounds = b;
        twitterFollowButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:twitterFollowButton];

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

- (void)followOnTwitter:(id)button {
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [[Mixpanel sharedInstance] track:kMPTwitterFollow];
    [[[Mixpanel sharedInstance] people] set:kMPTwitterFollow to:@(YES)];

    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError* error) {
        if (granted) {
            // Get the list of Twitter accounts.
            NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];

            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                for (ACAccount* twitterAccount in accountsArray) {
                    NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
                    [tempDict setValue:@"getlooseleaf" forKey:@"screen_name"];
                    [tempDict setValue:@"true" forKey:@"follow"];

                    SLRequest* followRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];

                    [followRequest setAccount:twitterAccount];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update UI to show success
                        [twitterFollowButton setTitle:@"..." forState:UIControlStateNormal];
                        [twitterFollowButton setUserInteractionEnabled:NO];
                    });

                    [followRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                        if (twitterAccount == accountsArray[0]) {
                            if (error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //Update UI to show follow request failed
                                    [twitterFollowButton setTitle:@"Error: could not follow" forState:UIControlStateNormal];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [twitterFollowButton setTitle:@"Follow @getlooseleaf" forState:UIControlStateNormal];
                                        [twitterFollowButton setUserInteractionEnabled:YES];
                                    });
                                });
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //Update UI to show success
                                    [twitterFollowButton setTitle:@"Followed! 🎉" forState:UIControlStateNormal];
                                    [twitterFollowButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                                    [twitterFollowButton setUserInteractionEnabled:NO];
                                });
                            }
                        }
                    }];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [twitterFollowButton setTitle:@"No twitter accounts configured" forState:UIControlStateNormal];
                    [twitterFollowButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    [twitterFollowButton setUserInteractionEnabled:NO];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [twitterFollowButton setTitle:@"No twitter accounts available" forState:UIControlStateNormal];
                [twitterFollowButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [twitterFollowButton setUserInteractionEnabled:NO];
            });
        }
    }];
}

- (void)noThanksButtonTapped:(id)button {
    [[MMTutorialManager sharedInstance] optOutOfNewsletter];
    [self.delegate didCompleteNewsletterStep];
}

#pragma mark - MMLoopView

- (BOOL)wantsNextButton {
    return NO;
}

- (BOOL)isBuffered {
    return NO;
}

- (BOOL)isAnimating {
    return [emailInput isFirstResponder];
}

- (void)startAnimating {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [emailInput becomeFirstResponder];
    });
}

- (void)pauseAnimating {
    [emailInput resignFirstResponder];
}

- (void)stopAnimating {
    [emailInput resignFirstResponder];
}

#pragma mark - Rotation

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    [self didRotateToIdealOrientation:orientation animated:YES];
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    CheckThreadMatches([NSThread isMainThread]);

    void (^block)() = ^{
        CGFloat widthOfButtons = signUpButton.bounds.size.width + noThanksButton.bounds.size.width + 20;
        CGFloat buttonMargin = (self.bounds.size.width - widthOfButtons) / 2;

        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown) {
            loopImage.center = CGPointMake(self.bounds.size.width / 2 + 50, 105);
            stayLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 80);
            inTheLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 110);
            emailInput.center = CGPointMake(self.bounds.size.width / 2, 250);
            validateInput.center = CGPointMake(self.bounds.size.width / 2, 280);
            signUpButton.center = CGPointMake(self.bounds.size.width - buttonMargin - signUpButton.bounds.size.width / 2, 330);
            noThanksButton.center = CGPointMake(buttonMargin + noThanksButton.bounds.size.width / 2, 330);
            pitchLbl.center = CGPointMake(self.bounds.size.width / 2, 195);
            twitterFollowButton.center = CGPointMake(self.bounds.size.width / 2, 400);
        } else {
            CGFloat moreMove = CGSizeMaxDim([[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size) <= 1024 ? 30 : 0;

            loopImage.center = CGPointMake(self.bounds.size.width / 2 + 50, 105 - moreMove);
            stayLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 80 - moreMove);
            inTheLbl.center = CGPointMake(self.bounds.size.width / 2 - 45, 110 - moreMove);
            emailInput.center = CGPointMake(self.bounds.size.width / 2, 220 - moreMove);
            validateInput.center = CGPointMake(self.bounds.size.width / 2, 250 - moreMove);
            signUpButton.center = CGPointMake(self.bounds.size.width - buttonMargin - signUpButton.bounds.size.width / 2, 300 - moreMove);
            noThanksButton.center = CGPointMake(buttonMargin + noThanksButton.bounds.size.width / 2, 300 - moreMove);
            pitchLbl.center = CGPointMake(self.bounds.size.width / 2, 180 - moreMove);
            twitterFollowButton.center = CGPointMake(self.bounds.size.width / 2, 400);
        }
        validateInputRed.center = validateInput.center;
    };

    if (animated) {
        [UIView animateWithDuration:.2 animations:block];
    } else {
        block();
    }
}


#pragma mark - UITextFieldDelegate

- (void)bounceEmailInput {
    [UIView animateWithDuration:1.0 animations:^{
        validateInputRed.alpha = 0;
    }];

    emailInput.layer.borderWidth = 1;
    emailInput.layer.borderColor = [UIColor lightGrayColor].CGColor;

    CGColorRef originalColor = emailInput.layer.borderColor;
    CGFloat originalWidth = emailInput.layer.borderWidth;

    CABasicAnimation* color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    // animate from red to blue border ...
    color.fromValue = (id)[UIColor redColor].CGColor;
    color.toValue = (__bridge id)originalColor;

    CABasicAnimation* width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    // animate from 2pt to 4pt wide border ...
    width.fromValue = @3;
    width.toValue = @(originalWidth);

    CAAnimationGroup* both = [CAAnimationGroup animation];
    // animate both as a group
    both.duration = .75;
    both.animations = @[color, width];
    both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    both.removedOnCompletion = YES;

    [emailInput.layer addAnimation:both forKey:@"color and width"];
}


// email validation from:
// http://stackoverflow.com/questions/9305373/validating-the-email-address-in-uitextfield
- (NSString*)validateInput {
    NSError* error = nil;
    NSDataDetector* detector =
        [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];

    __block NSString* matchedEmail = nil;
    NSString* string = emailInput.text;
    [detector enumerateMatchesInString:string
                               options:kNilOptions
                                 range:NSMakeRange(0, [string length])
                            usingBlock:^(NSTextCheckingResult* result,
                                         NSMatchingFlags flags, BOOL* stop) {
                                NSUInteger loc = [result.URL.absoluteString rangeOfString:@"mailto:"].location;
                                if (loc != NSNotFound) {
                                    matchedEmail = [result.URL.absoluteString substringFromIndex:[@"mailto:" length]];
                                }
                            }];

    validateInput.hidden = (matchedEmail != nil);
    validateInputRed.hidden = (matchedEmail != nil);
    validateInputRed.alpha = 1;
    if (!matchedEmail) {
        [self bounceEmailInput];
    }
    return matchedEmail;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    return [self didTapSubmitButton];
}

- (BOOL)didTapSubmitButton {
    NSString* validEmail = [self validateInput];
    if (validEmail) {
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
