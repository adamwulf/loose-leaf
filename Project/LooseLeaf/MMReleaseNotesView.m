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
#import "Mixpanel.h"

#define kFeedbackPlaceholderText @"Any feedback is very much appreciated!"

@interface MMReleaseNotesView ()<UITextViewDelegate>

@end

@implementation MMReleaseNotesView{
    MMReleaseNotesButtonPrompt* firstPromptView;
    MMReleaseNotesButtonPrompt* happyResponseView;
    
    UITextView* feedbackTextView;
    
    UIView* thanksView;
}

-(instancetype) initWithFrame:(CGRect)frame andReleaseNotes:(NSString*)htmlReleaseNotes{
    if(self = [super initWithFrame:frame]){
        
        self.allowTappingOutsideToClose = NO;
        
        UIView * content = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [content setBackgroundColor:[UIColor whiteColor]];
        [[self maskedScrollContainer] addSubview:content];
        
        UITextView* releaseNotesView = [[UITextView alloc] initWithFrame:[content bounds]];
        releaseNotesView.attributedText = [self formattedHTMLFromHTMLString:htmlReleaseNotes];
        releaseNotesView.textContainerInset = UIEdgeInsetsMake(40, 100, 140, 100);
        releaseNotesView.editable = NO;
        releaseNotesView.scrollIndicatorInsets = UIEdgeInsetsMake(80, 0, 142, 0);
        [content addSubview:releaseNotesView];
        
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
        
        
        
        UIView * feedbackForm = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [feedbackForm setBackgroundColor:[UIColor whiteColor]];
        feedbackForm.alpha = 0;
        
        CGRect promptFr = CGRectMake(100, 80, 400, 60);
        UILabel* promptLabel = [[UILabel alloc] initWithFrame:promptFr];
        promptLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        promptLabel.textAlignment = NSTextAlignmentCenter;
        promptLabel.text = @"What would make Loose Leaf better?";
        
        CGRect feedbackFrame = CGRectMake(100, 160, 400, 240);
        feedbackTextView = [[UITextView alloc] initWithFrame:feedbackFrame];
        [feedbackTextView setDelegate:self];
        [[feedbackTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[feedbackTextView layer] setBorderWidth:1];
        [feedbackTextView setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        
        UIButton* closeAnywayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        [[closeAnywayButton layer] setBorderColor:[[[UIColor blueShadowColor] colorWithAlphaComponent:1] CGColor]];
        [[closeAnywayButton layer] setBorderWidth:1];
        [[closeAnywayButton layer] setCornerRadius:8];
        [closeAnywayButton setClipsToBounds:YES];
        [closeAnywayButton setTitleColor:[[UIColor blueShadowColor] colorWithAlphaComponent:1] forState:UIControlStateNormal];
        [closeAnywayButton setTitleColor:[UIColor blueShadowColor] forState:UIControlStateNormal];
        [closeAnywayButton setTitle:@"No Feedback" forState:UIControlStateNormal];
        [[closeAnywayButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [closeAnywayButton addTarget:self action:@selector(closeFeedbackForm:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        sendButton.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [[sendButton layer] setCornerRadius:8];
        [sendButton setClipsToBounds:YES];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [sendButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
        [[sendButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [sendButton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat yOffset = CGRectGetHeight([[self maskedScrollContainer] bounds]) - 140;
        closeAnywayButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) - CGRectGetWidth([closeAnywayButton bounds]) - 60) / 2, yOffset);
        sendButton.center = CGPointMake((CGRectGetWidth([[self maskedScrollContainer] bounds]) + CGRectGetWidth([sendButton bounds]) + 60) / 2, yOffset);
        
        [feedbackForm addSubview:promptLabel];
        [feedbackForm addSubview:feedbackTextView];
        [feedbackForm addSubview:closeAnywayButton];
        [feedbackForm addSubview:sendButton];
        
        [[self maskedScrollContainer] addSubview:feedbackForm];
        
        
        
        
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=625659452&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];

            [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{kMPUpgradeFeedbackResult : @"Happy",
                                                                             kMPUpgradeAppStoreReview : @(YES)}];

            // below is the URL from itunes connect.
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/loose-leaf/id625659452"]];
        }];
        
        [happyResponseView setDenyBlock:^{
            [[weakSelf delegate] didTapToCloseRoundedSquareView:weakSelf];
            
            [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{kMPUpgradeFeedbackResult : @"Happy",
                                                                             kMPUpgradeAppStoreReview : @(NO)}];
            
        }];
        
        [content addSubview:promptContainerView];
        
        [self textViewDidEndEditing:feedbackTextView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [releaseNotesView flashScrollIndicators];
        });
    }
    return self;
}

#pragma mark - Feedback

-(void) sendFeedback:(UIButton*)button{
    [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{kMPUpgradeFeedbackResult : @"Sad",
                                                                     kMPUpgradeFeedbackReply : feedbackTextView.text ?: @""}];
    
    [UIView animateWithDuration:.3 animations:^{
        thanksView.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self delegate] didTapToCloseRoundedSquareView:self];
        });
    }];
}

-(void) closeFeedbackForm:(UIButton*)button{
    [[self delegate] didTapToCloseRoundedSquareView:self];

    [[Mixpanel sharedInstance] track:kMPUpgradeFeedback properties:@{kMPUpgradeFeedbackResult : @"Sad",
                                                                     kMPUpgradeFeedbackReply : feedbackTextView.text ?: @""}];
}


#pragma mark - Helper

-(NSAttributedString*) formattedHTMLFromHTMLString:(NSString*)htmlString{
    
    NSString* logoPath = [[[NSBundle mainBundle] URLForResource:@"logo" withExtension:@"png"] absoluteString];
    htmlString = [[NSString stringWithFormat:@"<center><img src='%@' height=80/></center><br>\n", logoPath] stringByAppendingString:htmlString];
    
    NSError* error;
    NSAttributedString *attString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)} documentAttributes:nil error:&error];
    
    
    NSMutableAttributedString* mutAttrStr = [attString mutableCopy];
    [attString enumerateAttribute:NSFontAttributeName
                          inRange:NSMakeRange(0, attString.length)
                          options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                       usingBlock:^(UIFont*  _Nullable font, NSRange range, BOOL * _Nonnull stop) {
                           [mutAttrStr removeAttribute:NSFontAttributeName range:range];
                           [mutAttrStr removeAttribute:NSForegroundColorAttributeName range:range];
                           if(font.pointSize > 14){
                               UIFontDescriptor* descriptor = [font fontDescriptor];
                               UIFontDescriptor* updatedFontDescriptor = [UIFontDescriptor fontDescriptorWithName:@"Lato-Bold" size:24];
                               UIFontDescriptor* descriptorWithTraits = [updatedFontDescriptor fontDescriptorWithSymbolicTraits:[descriptor symbolicTraits]];
                               updatedFontDescriptor = descriptorWithTraits ?: updatedFontDescriptor;
                               
                               font = [UIFont fontWithDescriptor:updatedFontDescriptor size:24];
                               [mutAttrStr addAttribute:NSFontAttributeName value:font range:range];
                               [mutAttrStr addAttribute:NSForegroundColorAttributeName
                                                  value:[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0] range:range];
                           }else{
                               UIFontDescriptor* descriptor = [font fontDescriptor];
                               UIFontDescriptor* updatedFontDescriptor = [UIFontDescriptor fontDescriptorWithName:@"Lato-Semibold" size:18];
                               UIFontDescriptor* descriptorWithTraits = [updatedFontDescriptor fontDescriptorWithSymbolicTraits:[descriptor symbolicTraits]];
                               updatedFontDescriptor = descriptorWithTraits ?: updatedFontDescriptor;
                               
                               font = [UIFont fontWithDescriptor:updatedFontDescriptor size:18];
                               [mutAttrStr addAttribute:NSFontAttributeName value:font range:range];
                               [mutAttrStr addAttribute:NSForegroundColorAttributeName
                                                  value:[UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1.0] range:range];
                           }
                       }];
    
    [attString enumerateAttribute:NSParagraphStyleAttributeName
                          inRange:NSMakeRange(0, attString.length)
                          options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                       usingBlock:^(NSParagraphStyle*  _Nullable style, NSRange range, BOOL * _Nonnull stop) {
                           [mutAttrStr removeAttribute:NSParagraphStyleAttributeName range:range];
                           NSMutableParagraphStyle* mutParaStyle = [style mutableCopy];
                           [mutParaStyle setParagraphSpacingBefore:14];
                           [mutAttrStr addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:range];
                       }];

    
    return mutAttrStr;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kFeedbackPlaceholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = kFeedbackPlaceholderText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
