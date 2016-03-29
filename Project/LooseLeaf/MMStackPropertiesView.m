//
//  MMStackPropertiesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackPropertiesView.h"
#import "MMAllStacksManager.h"
#import "UIPlaceHolderTextView.h"

@interface MMStackPropertiesView ()<UITextFieldDelegate>

@end

@implementation MMStackPropertiesView{
    NSString* stackUUID;
    UITextField* nameInput;
}

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)_stackUUID{
    if(self = [super initWithFrame:frame]){
        stackUUID = _stackUUID;
        
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.boxSize, self.boxSize)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.maskedScrollContainer addSubview:contentView];

        nameInput = [[UITextField alloc] initWithFrame:CGRectMake(60, 40, self.boxSize - 120, 50)];
        nameInput.font = [UIFont systemFontOfSize:26];
        nameInput.borderStyle = UITextBorderStyleRoundedRect;
        nameInput.textAlignment = NSTextAlignmentCenter;
        nameInput.textColor = [UIColor darkGrayColor];
        nameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameInput.placeholder = @"Tap to set name";
        nameInput.returnKeyType = UIReturnKeyDone;
        nameInput.delegate = self;
        [contentView addSubview:nameInput];
        
        nameInput.text = [[MMAllStacksManager sharedInstance] nameOfStack:stackUUID];
    }
    return self;
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[MMAllStacksManager sharedInstance] updateName:textField.text forStack:stackUUID];
}

@end
