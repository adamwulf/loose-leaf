//
//  UIFont+UIBezierCurve.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/25/12.
//
//

#import "UIFont+UIBezierCurve.h"
#import "Constants.h"


@implementation UIFont (UIBezierCurve)

-(UIBezierPath*) bezierPathForString:(NSString*) letter{
    UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;
    
    CFStringRef iString = (CFStringRef) letter;
    
    
    debug_NSLog(@"font name: %@", [self fontName]);
    CTFontRef iFont = CTFontCreateWithName((CFStringRef)[self fontName], [self pointSize], NULL);
    
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
    
    UIBezierPath* glyphPath = [UIBezierPath bezierPath];
    
    
    for(int i=0;i<count;i++){
        // Do something with the glyphs here, if a character is unmapped
        CGPathRef glyphCGPath = CTFontCreatePathForGlyph(iFont, glyphs[i], nil);
        CGFloat widthOfPrevChars = [glyphPath bounds].size.width + 6 * i;
        UIBezierPath* pathOfChar = [UIBezierPath bezierPathWithCGPath:glyphCGPath];
        [pathOfChar applyTransform:CGAffineTransformMakeTranslation(widthOfPrevChars, 0)];
        [glyphPath appendPath:pathOfChar];
    }
    
    // Free our buffers
    free(characters);
    free(glyphs);
    
    return glyphPath;
}
@end
