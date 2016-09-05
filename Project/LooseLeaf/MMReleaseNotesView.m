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

@implementation MMReleaseNotesView{
    MMReleaseNotesButtonPrompt* firstPromptView;
    MMReleaseNotesButtonPrompt* happyResponseView;
    MMReleaseNotesButtonPrompt* sadResponseView;
}

-(instancetype) initWithFrame:(CGRect)frame andReleaseNotes:(NSString*)htmlReleaseNotes{
    if(self = [super initWithFrame:frame]){
        
        self.allowTappingOutsideToClose = NO;
        
        UIView * content = [[UIView alloc] initWithFrame:[self.maskedScrollContainer bounds]];
        [content setBackgroundColor:[UIColor whiteColor]];
        [[self maskedScrollContainer] addSubview:content];
        
        UITextView* releaseNotesView =[[UITextView alloc] initWithFrame:[content bounds]];
        releaseNotesView.attributedText = [self formattedHTMLFromHTMLString:htmlReleaseNotes];
        releaseNotesView.textContainerInset = UIEdgeInsetsMake(40, 100, 140, 100);
        releaseNotesView.editable = NO;
        releaseNotesView.scrollIndicatorInsets = UIEdgeInsetsMake(80, 0, 80, 0);
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
        
        sadResponseView = [[MMReleaseNotesButtonPrompt alloc] initWithFrame:promptContainerView.bounds];
        sadResponseView.alpha = 0;
        [sadResponseView setPrompt:@"What could make Loose Leaf better?"];
        [sadResponseView setConfirmAnswer:@"Not sure"];
        [sadResponseView setDenyAnswer:@"I'll think about it"];
        
        [promptContainerView addSubview:sadResponseView];

        
        __weak MMReleaseNotesView* weakSelf = self;
        __weak UIView* weakFirstPrompt = firstPromptView;
        __weak UIView* weakHappyPrompt = happyResponseView;
        __weak UIView* weakSadPrompt = sadResponseView;
        
        [firstPromptView setConfirmBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                weakFirstPrompt.alpha = 0;
                weakHappyPrompt.alpha = 1;
            }];
        }];
        
        [firstPromptView setDenyBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                weakFirstPrompt.alpha = 0;
                weakSadPrompt.alpha = 1;
            }];
        }];
        
        [happyResponseView setConfirmBlock:^{
            [[weakSelf delegate] didTapToCloseRoundedSquareView:weakSelf];
            // This URL opens the review page (as of iOS 9) and has worked for at least 2 years
            // according to http://stackoverflow.com/questions/18905686/itunes-review-url-and-ios-7-ask-user-to-rate-our-app-appstore-show-a-blank-pag
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=625659452&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];

            // below is the URL from itunes connect.
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/loose-leaf/id625659452"]];
        }];
        
        [happyResponseView setDenyBlock:^{
            [[weakSelf delegate] didTapToCloseRoundedSquareView:weakSelf];
        }];
        
        [content addSubview:promptContainerView];
    }
    return self;
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

@end
