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

-(UIBezierPath*) getUIBezierPathForLetter:(NSString*) letter{
    UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;
    
    CFStringRef iString = (CFStringRef) letter;
    
    
    debug_NSLog(@"font name: %@", [self fontName]);
    CTFontRef ref = CTFontCreateWithName((CFStringRef)[self fontName], [self pointSize], NULL);
    CTFontRef iFont = nil;
//    if(traits){
//        iFont = CTFontCreateCopyWithSymbolicTraits(ref, fontSize, NULL, traits, traits);
//    }else{
        iFont = ref;
//    }
    
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
@end
