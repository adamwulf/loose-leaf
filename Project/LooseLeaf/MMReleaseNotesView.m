//
//  MMReleaseNotesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMReleaseNotesView.h"
#import "Constants.h"
#import "UIColor+Shadow.h"

@implementation MMReleaseNotesView{
    UIView* firstPromptView;
}

-(instancetype) initWithFrame:(CGRect)frame andReleaseNotes:(NSString*)htmlReleaseNotes{
    if(self = [super initWithFrame:frame]){
        
        
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
        
        
        firstPromptView = [[UIView alloc] initWithFrame:promptContainerView.bounds];
        
        UILabel* areYouEnjoyingLabel = [[UILabel alloc] initWithFrame:CGRectWithHeight(firstPromptView.bounds, 60)];
        areYouEnjoyingLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        areYouEnjoyingLabel.textAlignment = NSTextAlignmentCenter;
        areYouEnjoyingLabel.text = @"Are you enjoying Loose Leaf?";
        [firstPromptView addSubview:areYouEnjoyingLabel];
        
        UIButton* enjoyingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
        enjoyingButton.backgroundColor = [topLine backgroundColor];
        [[enjoyingButton layer] setCornerRadius:8];
        [enjoyingButton setClipsToBounds:YES];
        [enjoyingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [enjoyingButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [enjoyingButton setTitle:@"Definitely!" forState:UIControlStateNormal];
        [enjoyingButton addTarget:self action:@selector(isEnjoying:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* notEnjoyingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
        notEnjoyingButton.backgroundColor = [topLine backgroundColor];
        [[notEnjoyingButton layer] setCornerRadius:8];
        [notEnjoyingButton setClipsToBounds:YES];
        [notEnjoyingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notEnjoyingButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [notEnjoyingButton setTitle:@"Not so much" forState:UIControlStateNormal];
        [notEnjoyingButton addTarget:self action:@selector(notEnjoying:) forControlEvents:UIControlEventTouchUpInside];
        
        enjoyingButton.center = CGPointMake((CGRectGetWidth(firstPromptView.bounds) - CGRectGetWidth(enjoyingButton.bounds) - 60) / 2, 80);
        notEnjoyingButton.center = CGPointMake((CGRectGetWidth(firstPromptView.bounds) + CGRectGetWidth(notEnjoyingButton.bounds) + 60) / 2, 80);
        
        [promptContainerView addSubview:firstPromptView];
        [promptContainerView addSubview:enjoyingButton];
        [promptContainerView addSubview:notEnjoyingButton];
        
        
    }
    return self;
}

#pragma mark - First Prompt

-(void) isEnjoying:(UIButton*)button{
    
}

-(void) notEnjoying:(UIButton*)button{
    
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
