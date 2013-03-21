//
//  SLTextButton.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "MSSidebarButton.h"
#import <CoreText/CoreText.h>

@interface MSTextButton : MSSidebarButton{
    NSString* letter;
    CGFloat pointSize;
    CTFontSymbolicTraits traits;
    CGFloat xOffset;
    UIFont* font;
}

- (id)initWithFrame:(CGRect)_frame andFont:(UIFont*)_font andLetter:(NSString*)_letter andXOffset:(CGFloat)_xOffset;

@end
