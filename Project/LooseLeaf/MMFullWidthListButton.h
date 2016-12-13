//
//  MMFullWidthListButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/17/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMFullWidthListButtonDelegate.h"


@interface MMFullWidthListButton : UIView

- (instancetype)initWithFrame:(CGRect)frame andPrompt:(NSString*)prompt andLeftIcon:(UIImage*)leftIcon andLeftTitle:(NSString*)leftTitle andRightIcon:(UIImage*)rightIcon andRightTitle:(NSString*)rightTitle;

@property (nonatomic, weak) NSObject<MMFullWidthListButtonDelegate>* delegate;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, readonly) CGFloat additionalVerticalSpacing;

@end
