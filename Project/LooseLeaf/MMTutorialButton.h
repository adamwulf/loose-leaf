//
//  MMTutorialButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTextButton.h"

@interface MMTutorialButton : MMTextButton

-(id) initWithFrame:(CGRect)frame andFont:(UIFont *)font andLetter:(NSString *)letter andXOffset:(CGFloat)xOffset andYOffset:(CGFloat)yOffset NS_UNAVAILABLE;

-(id) initWithFrame:(CGRect)frame forStepNumber:(NSInteger)stepNumber;

@end
