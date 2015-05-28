//
//  MMEmailInputField.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMEmailInputField.h"

@implementation MMEmailInputField

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.placeholder = @"email";
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = 10;
        self.keyboardType = UIKeyboardTypeEmailAddress;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.enablesReturnKeyAutomatically = NO;
        self.returnKeyType = UIReturnKeyDone;
        self.clearsOnBeginEditing = NO;
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds{
    if(bounds.size.width > 20){
        bounds.origin.x += 10;
        bounds.size.width -= 20;
    }
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}

-(CGRect) placeholderRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}

@end
