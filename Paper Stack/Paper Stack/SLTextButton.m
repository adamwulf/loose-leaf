//
//  SLPlusButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLTextButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLTextButton

- (id)initWithFrame:(CGRect)_frame andFont:(UIFont*)_font andLetter:(NSString*)_letter andTraits:(CTFontSymbolicTraits)_traits andXOffset:(CGFloat)_xOffset{
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        fontName = [_font fontName];
        letter = _letter;
        pointSize = [_font pointSize] * kWidthOfSidebarButton / 50.0;
        traits = _traits;
        xOffset = _xOffset;
    }
    return self;
}

-(UIBezierPath*) getUIBezierPathForSize:(CGFloat) fontSize{
    UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;
    
    CFStringRef iString = (CFStringRef) letter;
    
    CTFontRef ref = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    CTFontRef iFont = nil;
    if(traits){
        iFont = CTFontCreateCopyWithSymbolicTraits(ref, fontSize, NULL, traits, traits);
    }else{
        iFont = ref;
    }

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
    CGContextRef context = UIGraphicsGetCurrentContext();  
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    CGContextSaveGState(context);
    
    UIBezierPath* glyphPath = [self getUIBezierPathForSize:scaledPointSize];
    CGRect glyphRect = [glyphPath bounds];
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5 + xOffset, -glyphRect.size.height),
                                                              CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer,
                                                               (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer)];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [ovalPath appendPath:glyphPath];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];

    
    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [glyphPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setFill];
    [glyphPath fill];
    
    CGContextRestoreGState(context);
    
}


@end
