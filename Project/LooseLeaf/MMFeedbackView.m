//
//  MMFeedbackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackView.h"
#import "MMReleaseNotesButtonPrompt.h"
#import "Constants.h"
#import "UIColor+Shadow.h"
#import "Mixpanel.h"
#import "MMAppDelegate.h"
#import "MMEmailInputField.h"

#define kFeedbackPlaceholderText @"Any feedback is very much appreciated!"


@interface MMFeedbackView () <UITextViewDelegate, UITextFieldDelegate>

@end


@implementation MMFeedbackView {
    MMReleaseNotesButtonPrompt* firstPromptView;
    MMReleaseNotesButtonPrompt* happyResponseView;

    CGRect idealLogoImageViewFrame;
    CGRect idealFeedbackLabelFrame;
    CGRect idealFeedbackTextViewFrame;
    CGRect idealCloseButtonFrame;
    CGRect idealSendButtonFrame;

    UIImageView* logoImageView;
    UILabel* feedbackPromptLabel;
    UITextView* feedbackTextView;
    UIButton* closeAnywayButton;
    UIButton* sendButton;

    UIView* thanksView;
    
    UILabel* emailPrompt;
    MMEmailInputField* emailInput;
    UILabel* validateInput;
    UILabel* validateInputRed;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.allowTappingOutsideToClose = NO;

        UIView* content = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [content setBackgroundColor:[UIColor whiteColor]];
        [[self maskedScrollContainer] addSubview:content];

        UIView* feedbackForm = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [feedbackForm setBackgroundColor:[UIColor whiteColor]];
        feedbackForm.alpha = 0;

        UIImage* logoImg = [UIImage imageNamed:@"logo"];

        logoImageView = [[UIImageView alloc] initWithImage:logoImg];
        CGRect fr = logoImageView.bounds;
        fr.size.width *= .75;
        fr.size.height *= .75;
        logoImageView.bounds = fr;
        logoImageView.center = CGPointMake(CGRectGetWidth([[self maskedScrollContainer] bounds]) / 2, 80);

        CGRect promptFr = CGRectMake(100, 110, 400, 60);
        feedbackPromptLabel = [[UILabel alloc] initWithFrame:promptFr];
        feedbackPromptLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        feedbackPromptLabel.textAlignment = NSTextAlignmentCenter;
        feedbackPromptLabel.text = @"What would make Loose Leaf better?";

        CGRect feedbackFrame = CGRectMake(100, 190, 420, 200);
        feedbackTextView = [[UITextView alloc] initWithFrame:feedbackFrame];
        [feedbackTextView setDelegate:self];
        [[feedbackTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[feedbackTextView layer] setBorderWidth:1];
        [feedbackTextView setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];

        validateInput = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 460, 40)];
        validateInput.text = @"Please enter a valid email address.";
        validateInput.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        validateInput.textAlignment = NSTextAlignmentCenter;
        validateInput.hidden = YES;
        
        validateInputRed = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 460, 40)];
        validateInputRed.text = @"Please enter a valid email address.";
        validateInputRed.textColor = [UIColor redColor];
        validateInputRed.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        validateInputRed.textAlignment = NSTextAlignmentCenter;
        validateInputRed.hidden = YES;
        
        // form
        emailInput = [[MMEmailInputField alloc] initWithFrame:CGRectMake(0, 200, 320, 30)];
        emailInput.placeholder = @"optional";
        emailInput.text = [MMAppDelegate email];
        emailInput.delegate = self;

        emailPrompt = [[UILabel alloc] init];
        emailPrompt.font = [UIFont fontWithName:@"Lato-Semibold" size:16];
        emailPrompt.text = @"Your Email";
        [emailPrompt sizeToFit];

        emailInput.center = CGPointMake(CGRectGetMaxX([feedbackTextView frame]) - CGRectGetWidth([emailInput bounds]) / 2, CGRectGetMaxY(feedbackFrame) + 30);
        validateInput.center = CGPointMake(CGRectGetWidth([feedbackForm bounds]) / 2, emailInput.center.y + 30);
        validateInputRed.center = validateInput.center;
        emailPrompt.center = CGPointMake(CGRectGetWidth([emailPrompt bounds]) / 2 + CGRectGetMinX([feedbackTextView frame]), emailInput.center.y);
        
        closeAnywayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        [[closeAnywayButton layer] setBorderColor:[[[UIColor blueShadowColor] colorWithAlphaComponent:1] CGColor]];
        [[closeAnywayButton layer] setBorderWidth:1];
        [[closeAnywayButton layer] setCornerRadius:8];
        [closeAnywayButton setClipsToBounds:YES];
        [closeAnywayButton setTitleColor:[[UIColor blueShadowColor] colorWithAlphaComponent:1] forState:UIControlStateNormal];
        [closeAnywayButton setTitleColor:[UIColor blueShadowColor] forState:UIControlStateNormal];
        [closeAnywayButton setTitle:@"No Feedback" forState:UIControlStateNormal];
        [[closeAnywayButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [closeAnywayButton addTarget:self action:@selector(closeFeedbackForm:) forControlEvents:UIControlEventTouchUpInside];

        sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        sendButton.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [[sendButton layer] setCornerRadius:8];
        [sendButton setClipsToBounds:YES];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [sendButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
        [[sendButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [sendButton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat yOffset = CGRectGetHeight([[self maskedScrollContainer] bounds]) - 100;
        closeAnywayButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) - CGRectGetWidth([closeAnywayButton bounds]) - 60) / 2, yOffset);
        sendButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) + CGRectGetWidth([sendButton bounds]) + 60) / 2, yOffset);

        [feedbackForm addSubview:logoImageView];
        [feedbackForm addSubview:feedbackPromptLabel];
        [feedbackForm addSubview:feedbackTextView];
        [feedbackForm addSubview:emailPrompt];
        [feedbackForm addSubview:emailInput];
        [feedbackForm addSubview:validateInput];
        [feedbackForm addSubview:validateInputRed];
        [feedbackForm addSubview:closeAnywayButton];
        [feedbackForm addSubview:sendButton];
        feedbackForm.alpha = 1;

        [[self maskedScrollContainer] addSubview:feedbackForm];

        idealLogoImageViewFrame = logoImageView.frame;
        idealFeedbackLabelFrame = feedbackPromptLabel.frame;
        idealFeedbackTextViewFrame = feedbackTextView.frame;
        idealCloseButtonFrame = closeAnywayButton.frame;
        idealSendButtonFrame = sendButton.frame;

        thanksView = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [thanksView setBackgroundColor:[UIColor whiteColor]];
        thanksView.alpha = 0;

        UILabel* thanksLabel = [[UILabel alloc] initWithFrame:[thanksView bounds]];
        thanksLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        thanksLabel.textAlignment = NSTextAlignmentCenter;
        thanksLabel.text = @"Thanks for your feedback!\n😄";
        thanksLabel.numberOfLines = 0;

        [thanksView addSubview:thanksLabel];
        [[self maskedScrollContainer] addSubview:thanksView];

        [self textViewDidEndEditing:feedbackTextView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardFrameDidChange:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Keyboard

- (void)keyboardFrameDidChange:(NSNotification*)notification {
    NSValue* endFrame = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [endFrame CGRectValue];
    CGRect idealFeedbackFrameInWindow = [[self maskedScrollContainer] convertRect:idealFeedbackTextViewFrame toView:nil];
    CGFloat emailOffset = 0;

    if (CGRectIntersectsRect(idealFeedbackFrameInWindow, keyboardFrame)) {
        logoImageView.frame = CGRectOffset(idealLogoImageViewFrame, 0, -20);
        feedbackPromptLabel.frame = CGRectOffset(idealFeedbackLabelFrame, 0, -30);
        feedbackTextView.frame = CGRectOffset(CGRectResizeBy(idealFeedbackTextViewFrame, 0, -118), 0, -40);
        closeAnywayButton.frame = CGRectOffset(idealCloseButtonFrame, 0, -178);
        sendButton.frame = CGRectOffset(idealSendButtonFrame, 0, -178);
        emailOffset = -4;
    } else {
        logoImageView.frame = idealLogoImageViewFrame;
        feedbackPromptLabel.frame = idealFeedbackLabelFrame;
        feedbackTextView.frame = idealFeedbackTextViewFrame;
        closeAnywayButton.frame = idealCloseButtonFrame;
        sendButton.frame = idealSendButtonFrame;
    }

    CGRect feedbackFrame = [feedbackTextView frame];
    emailInput.center = CGPointMake(CGRectGetMaxX([feedbackTextView frame]) - CGRectGetWidth([emailInput bounds]) / 2, CGRectGetMaxY(feedbackFrame) + 30 + emailOffset);
    validateInput.center = CGPointMake(CGRectGetWidth([self.maskedScrollContainer bounds]) / 2, emailInput.center.y + 30 + emailOffset);
    validateInputRed.center = validateInput.center;
    emailPrompt.center = CGPointMake(CGRectGetWidth([emailPrompt bounds]) / 2 + CGRectGetMinX([feedbackTextView frame]), emailInput.center.y);
}

#pragma mark - Feedback

- (void)sendFeedback:(UIButton*)button {
    if([self validateAndSaveEmailAddressField]){
        NSString* feedbackText = feedbackTextView.text ?: @"";
        NSString* email = [emailInput text];

        if([email length] > 0){
            [MMAppDelegate setEmail:email];
        }
        
        if (![feedbackText isEqualToString:kFeedbackPlaceholderText]) {
            
            NSArray<NSString*>* feedbacks = @[];
            
            while ([feedbackText length]) {
                if([feedbackText length] > 255){
                    feedbacks = [feedbacks arrayByAddingObject:[feedbackText substringToIndex:255]];
                    feedbackText = [feedbackText substringFromIndex:255];
                }else{
                    feedbacks = [feedbacks arrayByAddingObject:feedbackText];
                    feedbackText = @"";
                }
            }
            
            // track longer strings into the event as well
            NSMutableDictionary* properties = [@{ kMPUpgradeFeedbackResult: @"Neutral",
                                                 kMPEmailAddressField : [MMAppDelegate email] ?: @"none" } mutableCopy];
            
            for (int i=0; i<[feedbacks count]; i++) {
                NSString* feedback = feedbacks[i];
                NSString* key = kMPUpgradeFeedbackReply;
                if(i > 0){
                    key = [NSString stringWithFormat:@"%@ %d", kMPUpgradeFeedbackReply, i+1];
                }
                properties[key] = feedback;
            }
            
            [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:properties];
        }
        
        [feedbackTextView resignFirstResponder];
        
        [UIView animateWithDuration:.3 animations:^{
            thanksView.alpha = 1;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self delegate] didTapToCloseRoundedSquareView:self];
            });
        }];
    }
}

- (void)closeFeedbackForm:(UIButton*)button {
    [[self delegate] didTapToCloseRoundedSquareView:self];

    [feedbackTextView resignFirstResponder];

    NSString* feedbackText = feedbackTextView.text ?: @"";

    if (![feedbackText isEqualToString:kFeedbackPlaceholderText]){
        [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Neutral",
                                                                          kMPUpgradeFeedbackReply: feedbackText,
                                                                          kMPEmailAddressField : [MMAppDelegate email] ?: @"none" }];
    }
}


#pragma mark - Helper

- (NSAttributedString*)formattedHTMLFromHTMLString:(NSString*)htmlString {
    NSString* logoPath = [[[NSBundle mainBundle] URLForResource:@"logo" withExtension:@"png"] absoluteString];
    htmlString = [[NSString stringWithFormat:@"<center><img src='%@' height=80/></center><br>\n", logoPath] stringByAppendingString:htmlString];

    NSError* error;
    NSAttributedString* attString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                          documentAttributes:nil
                                                                       error:&error];


    NSMutableAttributedString* mutAttrStr = [attString mutableCopy];
    [attString enumerateAttribute:NSFontAttributeName
                          inRange:NSMakeRange(0, attString.length)
                          options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                       usingBlock:^(UIFont* _Nullable font, NSRange range, BOOL* _Nonnull stop) {
                           [mutAttrStr removeAttribute:NSFontAttributeName range:range];
                           [mutAttrStr removeAttribute:NSForegroundColorAttributeName range:range];
                           if (font.pointSize > 14) {
                               UIFontDescriptor* descriptor = [font fontDescriptor];
                               UIFontDescriptor* updatedFontDescriptor = [UIFontDescriptor fontDescriptorWithName:@"Lato-Bold" size:24];
                               UIFontDescriptor* descriptorWithTraits = [updatedFontDescriptor fontDescriptorWithSymbolicTraits:[descriptor symbolicTraits]];
                               updatedFontDescriptor = descriptorWithTraits ?: updatedFontDescriptor;

                               font = [UIFont fontWithDescriptor:updatedFontDescriptor size:24];
                               [mutAttrStr addAttribute:NSFontAttributeName value:font range:range];
                               [mutAttrStr addAttribute:NSForegroundColorAttributeName
                                                  value:[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0]
                                                  range:range];
                           } else {
                               UIFontDescriptor* descriptor = [font fontDescriptor];
                               UIFontDescriptor* updatedFontDescriptor = [UIFontDescriptor fontDescriptorWithName:@"Lato-Semibold" size:18];
                               UIFontDescriptor* descriptorWithTraits = [updatedFontDescriptor fontDescriptorWithSymbolicTraits:[descriptor symbolicTraits]];
                               updatedFontDescriptor = descriptorWithTraits ?: updatedFontDescriptor;

                               font = [UIFont fontWithDescriptor:updatedFontDescriptor size:18];
                               [mutAttrStr addAttribute:NSFontAttributeName value:font range:range];
                               [mutAttrStr addAttribute:NSForegroundColorAttributeName
                                                  value:[UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1.0]
                                                  range:range];
                           }
                       }];

    [attString enumerateAttribute:NSParagraphStyleAttributeName
                          inRange:NSMakeRange(0, attString.length)
                          options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                       usingBlock:^(NSParagraphStyle* _Nullable style, NSRange range, BOOL* _Nonnull stop) {
                           [mutAttrStr removeAttribute:NSParagraphStyleAttributeName range:range];
                           NSMutableParagraphStyle* mutParaStyle = [style mutableCopy];
                           [mutParaStyle setParagraphSpacingBefore:14];
                           [mutAttrStr addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:range];
                       }];


    return mutAttrStr;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView*)textView {
    if ([textView.text isEqualToString:kFeedbackPlaceholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView*)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = kFeedbackPlaceholderText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
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
    return [self validateAndSaveEmailAddressField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField.text length]){
        [self validateInput];
    }else{
        validateInput.hidden = YES;
        validateInputRed.hidden = YES;
    }
}

- (BOOL)validateAndSaveEmailAddressField {
    if(emailInput.text.length == 0){
        // empty email is allowed
        [emailInput resignFirstResponder];
        return YES;
    } else {
        NSString* validEmail = [self validateInput];
        
        if (validEmail) {
            // valid email is allowed
            [MMAppDelegate setEmail:validEmail];
            [emailInput resignFirstResponder];
            
            [self sendFeedback:nil];
            
            return YES;
        }
    }
    return NO;
}

@end
