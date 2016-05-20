//
//  MMStackPropertiesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackPropertiesView.h"
#import "MMAllStacksManager.h"
#import "MMSingleStackManager.h"
#import "MMStackIconView.h"

@interface MMStackPropertiesView ()<UITextFieldDelegate>

@end

@implementation MMStackPropertiesView{
    NSString* stackUUID;
    UITextField* nameInput;
    MMStackIconView* icon;
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
        
        CGFloat stackIconHeight = 340;
        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        CGFloat scale = stackIconHeight / CGRectGetHeight(screenBounds);
        CGRect thumbFrame = CGRectApplyAffineTransform(screenBounds, CGAffineTransformMakeScale(scale, scale));
        icon = [[MMStackIconView alloc] initWithFrame:thumbFrame andStackUUID:stackUUID andStyle:MMStackIconViewStyleLight];
        [icon loadThumbs];
        [contentView addSubview:icon];
        
        icon.center = CGPointMake(CGRectGetMidX(contentView.bounds), CGRectGetMidY(contentView.bounds));
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
