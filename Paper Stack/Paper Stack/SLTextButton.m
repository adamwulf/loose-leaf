//
//  SLPlusButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLTextButton.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "Constants.h"

@implementation SLTextButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

UIBezierPath* GetUIBezierPathForCharacters(CFStringRef iString)
{
    UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;

    CTFontRef ref = CTFontCreateWithName((CFStringRef)@"Helvetica", 20, NULL);
    CTFontRef iFont = CTFontCreateCopyWithSymbolicTraits(ref, 20, NULL, kCTFontItalicTrait, kCTFontItalicTrait);

    assert(iFont != NULL && iString != NULL);
    
    // Get our string length.
    count = CFStringGetLength(iString);
    
    // Allocate our buffers for characters and glyphs.
    characters = (UniChar *)malloc(sizeof(UniChar) * count);
    assert(characters != NULL);
    
    glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert(glyphs != NULL);
    
    // Get the characters from the string.
    CFStringGetCharacters(iString, CFRangeMake(0, count), characters);
    
    // Get the glyphs for the characters.
    CTFontGetGlyphsForCharacters(iFont, characters, glyphs, count);
    
    // Do something with the glyphs here, if a character is unmapped
    CGPathRef glyphCGPath = CTFontCreatePathForGlyph(iFont, glyphs[0], nil);
    UIBezierPath* glyphPath = [UIBezierPath bezierPathWithCGPath:glyphCGPath];

    
    // Free our buffers
    free(characters);
    free(glyphs);
    
    return glyphPath;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat smallest2 = MIN([self.layer.presentationLayer frame].size.width, [self.layer.presentationLayer frame ].size.height);
    debug_NSLog(@"size: %f vs %f", smallest, smallest2);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    UIBezierPath* glyphPath = GetUIBezierPathForCharacters((CFStringRef)@"T");
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [ovalPath appendPath:glyphPath];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
}


@end
