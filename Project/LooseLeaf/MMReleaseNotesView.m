//
//  MMReleaseNotesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMReleaseNotesView.h"
#import "MMReleaseNotesButtonPrompt.h"
#import "Constants.h"
#import "UIColor+Shadow.h"
#import "MMLoopingVideoView.h"
#import "Mixpanel.h"
#import <StoreKit/StoreKit.h>

#define kFeedbackPlaceholderText @"Any feedback is very much appreciated!"


@interface MMReleaseNotesView () <UITextViewDelegate>

@end


@implementation MMReleaseNotesView {
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

    UIScrollView* scrollView;

    UIView* thanksView;
}

- (instancetype)initWithFrame:(CGRect)frame andReleaseNotes:(NSString*)htmlReleaseNotes {
    if (self = [super initWithFrame:frame]) {
        self.allowTappingOutsideToClose = NO;

        UIView* content = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [content setBackgroundColor:[UIColor whiteColor]];
        [[self maskedScrollContainer] addSubview:content];

        NSArray* allFormatedText = [self formattedHTMLFromHTMLString:htmlReleaseNotes];

        scrollView = [[UIScrollView alloc] initWithFrame:[content bounds]];
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(80, 0, 142, 0);

        CGFloat y = 48;
        for (NSObject* str in allFormatedText) {
            if ([str isKindOfClass:[NSAttributedString class]]) {
                CGRect r = CGRectWithHeight([content bounds], CGFLOAT_MAX);
                r.origin.x += 100;
                r.size.width -= 200;
                r.origin.y = y;
                UILabel* lbl = [[UILabel alloc] initWithFrame:r];
                lbl.attributedText = (NSAttributedString*)str;
                lbl.numberOfLines = 0;
                [lbl sizeToFit];

                r = lbl.frame;
                r.origin.y = y;
                lbl.frame = r;

                y += CGRectGetHeight([lbl bounds]);

                [scrollView addSubview:lbl];
            } else {
                NSURL* assetURL = (NSURL*)str;

                y -= 10;

                if ([MMLoopingVideoView supportsURL:assetURL]) {
                    CGFloat margin = 120;
                    CGFloat maxDim = MAX(CGRectGetWidth([content bounds]), CGRectGetHeight([content bounds]));
                    maxDim -= 2 * margin;
                    CGRect videoFrame = CGRectMake(margin, y, maxDim, maxDim);
                    MMLoopingVideoView* video = [[MMLoopingVideoView alloc] initForVideo:(NSURL*)str withFrame:videoFrame];
                    [scrollView addSubview:video];

                    [video startAnimating];
                    y += CGRectGetHeight(videoFrame);
                } else {
                    UIImage* img = [UIImage imageNamed:[[assetURL path] lastPathComponent]];
                    UIImageView* imageView = [[UIImageView alloc] initWithImage:img];
                    CGPoint center = CGRectGetMidPoint([content bounds]);
                    center.y = y + CGRectGetHeight([imageView bounds]) / 2;
                    imageView.center = center;
                    [scrollView addSubview:imageView];

                    y += CGRectGetHeight([imageView bounds]);
                }
                y += 20;
            }
        }

        y += 130;

        [content addSubview:scrollView];
        [scrollView setContentSize:CGSizeMake(CGRectGetWidth([content bounds]), y)];

        CGFloat promptHeight = 140;
        UIView* promptContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([content bounds]) - promptHeight, CGRectGetWidth([content bounds]), promptHeight)];
        promptContainerView.backgroundColor = [UIColor whiteColor];
        UIView* topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([content bounds]), 2)];
        topLine.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [promptContainerView addSubview:topLine];
        [content addSubview:promptContainerView];


        firstPromptView = [[MMReleaseNotesButtonPrompt alloc] initWithFrame:promptContainerView.bounds];
        [firstPromptView setPrompt:@"Are you enjoying Loose Leaf?"];
        [firstPromptView setConfirmAnswer:@"Definitely! 😄"];
        [firstPromptView setDenyAnswer:@"Not so much 😞"];

        [promptContainerView addSubview:firstPromptView];

        happyResponseView = [[MMReleaseNotesButtonPrompt alloc] initWithFrame:promptContainerView.bounds];
        happyResponseView.alpha = 0;
        [happyResponseView setPrompt:@"Awesome! Will you rate us on the App Store?"];
        [happyResponseView setConfirmAnswer:@"⭐️⭐️⭐️⭐️⭐️"];
        [happyResponseView setDenyAnswer:@"No Thanks"];

        [promptContainerView addSubview:happyResponseView];


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

        CGRect feedbackFrame = CGRectMake(100, 190, 420, 220);
        feedbackTextView = [[UITextView alloc] initWithFrame:feedbackFrame];
        [feedbackTextView setDelegate:self];
        [[feedbackTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[feedbackTextView layer] setBorderWidth:1];
        [feedbackTextView setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];

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

        CGFloat yOffset = CGRectGetHeight([[self maskedScrollContainer] bounds]) - 120;
        closeAnywayButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) - CGRectGetWidth([closeAnywayButton bounds]) - 60) / 2, yOffset);
        sendButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) + CGRectGetWidth([sendButton bounds]) + 60) / 2, yOffset);

        [feedbackForm addSubview:logoImageView];
        [feedbackForm addSubview:feedbackPromptLabel];
        [feedbackForm addSubview:feedbackTextView];
        [feedbackForm addSubview:closeAnywayButton];
        [feedbackForm addSubview:sendButton];

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


        __weak MMReleaseNotesView* weakSelf = self;
        __weak UIView* weakFirstPrompt = firstPromptView;
        __weak UIView* weakHappyPrompt = happyResponseView;

        [firstPromptView setConfirmBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                weakFirstPrompt.alpha = 0;
                weakHappyPrompt.alpha = 1;

                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfHappyUpgrades by:@(1)];
            }];
        }];

        [firstPromptView setDenyBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfSadUpgrades by:@(1)];
                weakFirstPrompt.alpha = 0;
                feedbackForm.alpha = 1;
            }];
        }];

        [happyResponseView setConfirmBlock:^{
            [[weakSelf delegate] didTapToCloseRoundedSquareView:weakSelf];
            
            // This URL opens the review page (as of iOS 9) and has worked for at least 2 years
            // according to http://stackoverflow.com/questions/18905686/itunes-review-url-and-ios-7-ask-user-to-rate-our-app-appstore-show-a-blank-pag
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=625659452&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&action=write-review"]];

            [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Happy",
                                                                              kMPUpgradeAppStoreReview: @(YES) }];

            // below is the URL from itunes connect.
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/loose-leaf/id625659452"]];
        }];

        [happyResponseView setDenyBlock:^{
            [[weakSelf delegate] didTapToCloseRoundedSquareView:weakSelf];

            [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Happy",
                                                                              kMPUpgradeAppStoreReview: @(NO) }];

        }];

        [content addSubview:promptContainerView];

        [self textViewDidEndEditing:feedbackTextView];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scrollView flashScrollIndicators];
        });

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

    if (CGRectIntersectsRect(idealFeedbackFrameInWindow, keyboardFrame)) {
        logoImageView.frame = CGRectOffset(idealLogoImageViewFrame, 0, -20);
        feedbackPromptLabel.frame = CGRectOffset(idealFeedbackLabelFrame, 0, -30);
        feedbackTextView.frame = CGRectOffset(CGRectResizeBy(idealFeedbackTextViewFrame, 0, -118), 0, -40);
        closeAnywayButton.frame = CGRectOffset(idealCloseButtonFrame, 0, -178);
        sendButton.frame = CGRectOffset(idealSendButtonFrame, 0, -178);
    } else {
        logoImageView.frame = idealLogoImageViewFrame;
        feedbackPromptLabel.frame = idealFeedbackLabelFrame;
        feedbackTextView.frame = idealFeedbackTextViewFrame;
        closeAnywayButton.frame = idealCloseButtonFrame;
        sendButton.frame = idealSendButtonFrame;
    }
}

#pragma mark - Feedback

- (void)sendFeedback:(UIButton*)button {
    NSString* feedbackText = feedbackTextView.text ?: @"";
    
    if ([feedbackText isEqualToString:kFeedbackPlaceholderText]) {
        [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Sad" }];
    }else{
        [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Sad",
                                                                          kMPUpgradeFeedbackReply: feedbackText }];
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

- (void)closeFeedbackForm:(UIButton*)button {
    [[self delegate] didTapToCloseRoundedSquareView:self];

    [feedbackTextView resignFirstResponder];

    NSString* feedbackText = feedbackTextView.text ?: @"";

    if ([feedbackText isEqualToString:kFeedbackPlaceholderText]) {
        [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Sad" }];
    }else{
        [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{ kMPUpgradeFeedbackResult: @"Sad",
                                                                          kMPUpgradeFeedbackReply: feedbackText }];
    }
}


#pragma mark - Helper

- (NSArray<NSAttributedString*>*)formattedHTMLFromHTMLString:(NSString*)htmlString {
    NSString* logoPath = [[[NSBundle mainBundle] URLForResource:@"logo" withExtension:@"png"] absoluteString];
    htmlString = [[NSString stringWithFormat:@"<center><img src='%@' height=80/></center><br>\n", logoPath] stringByAppendingString:htmlString];

    NSRange rng = [htmlString rangeOfString:@"<ol>"];
    htmlString = [htmlString stringByReplacingCharactersInRange:rng withString:@"<ol start=1>"];
    rng = [htmlString rangeOfString:@"<ol>"];
    htmlString = [htmlString stringByReplacingCharactersInRange:rng withString:@"<ol start=2>"];
    rng = [htmlString rangeOfString:@"<ol>"];
    htmlString = [htmlString stringByReplacingCharactersInRange:rng withString:@"<ol start=3>"];


    NSMutableArray* components = [NSMutableArray array];

    while ([htmlString rangeOfString:@"\\[(.*)\\]" options:NSRegularExpressionSearch].location != NSNotFound) {
        NSRange rng = [htmlString rangeOfString:@"\\[(.*)\\]" options:NSRegularExpressionSearch];
        NSString* str = [htmlString substringToIndex:rng.location];
        if ([str hasSuffix:@"<p>"]) {
            str = [str stringByReplacingCharactersInRange:[str rangeOfString:@"<p>" options:NSBackwardsSearch] withString:@""];
        }
        [components addObject:str];

        NSString* video = [[htmlString substringWithRange:rng] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
        NSString* ext = [video pathExtension];
        NSString* filename = [video substringToIndex:[video rangeOfString:@"."].location];
        NSURL* url = [[NSBundle mainBundle] URLForResource:filename withExtension:ext];
        if (url) {
            [components addObject:url];
        }

        htmlString = [htmlString substringFromIndex:rng.location + rng.length];
        if ([htmlString hasPrefix:@"</p>"]) {
            htmlString = [htmlString stringByReplacingCharactersInRange:[htmlString rangeOfString:@"</p>"] withString:@""];
        }
    }
    [components addObject:htmlString];


    NSMutableArray* allReleaseNoteComponents = [NSMutableArray array];

    for (NSString* htmlSegment in components) {
        if ([htmlSegment isKindOfClass:[NSURL class]]) {
            [allReleaseNoteComponents addObject:htmlSegment];
            continue;
        }

        NSError* error;
        NSAttributedString* attString = [[NSAttributedString alloc] initWithData:[htmlSegment dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
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

        [allReleaseNoteComponents addObject:mutAttrStr];
    }

    return allReleaseNoteComponents;
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

@end
