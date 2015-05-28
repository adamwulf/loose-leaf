//
//  MMTextButton.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMDarkSidebarButton.h"
#import <CoreText/CoreText.h>

@interface MMTextButton : MMSidebarButton{
    NSString* letter;
    CGFloat pointSize;
    CTFontSymbolicTraits traits;
    CGFloat xOffset;
    CGFloat yOffset;
    UIFont* font;
}

@property (assign) BOOL inverted;

- (id)initWithFrame:(CGRect)_frame andFont:(UIFont*)_font andLetter:(NSString*)_letter andXOffset:(CGFloat)_xOffset andYOffset:(CGFloat)_yOffset;

@end
