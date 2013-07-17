//
//  UIFont+UIBezierCurve.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/25/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIFont+UIBezierCurve.h"
#import "Constants.h"


@implementation UIFont (UIBezierCurve)

static NSMutableDictionary* _pathCacheInstance = nil;

+(NSMutableDictionary*) sharedPathCache{
    if(!_pathCacheInstance){
        _pathCacheInstance = [[NSMutableDictionary alloc]init];
    }
    return _pathCacheInstance;
}

-(UIBezierPath*) bezierPathForString:(NSString*) letter{
    NSString* key = [NSString stringWithFormat:@"%@%f - %@", [self fontName], [self pointSize], letter];
    
    UIBezierPath* glyphPath = [[UIFont sharedPathCache] objectForKey:key];
    if(!glyphPath){
        
        
        UniChar *characters;
        CGGlyph *glyphs;
        CFIndex count;
        
        CFStringRef iString = (__bridge CFStringRef) letter;
        
        CTFontRef iFont = CTFontCreateWithName((__bridge CFStringRef)[self fontName], [self pointSize], NULL);
        
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
        
        glyphPath = [UIBezierPath bezierPath];
        
        
        for(int i=0;i<count;i++){
            // Do something with the glyphs here, if a character is unmapped
            CGPathRef glyphCGPath = CTFontCreatePathForGlyph(iFont, glyphs[i], nil);
            CGFloat widthOfPrevChars = [glyphPath bounds].size.width + 6 * i;
            UIBezierPath* pathOfChar = [UIBezierPath bezierPathWithCGPath:glyphCGPath];
            [pathOfChar applyTransform:CGAffineTransformMakeTranslation(widthOfPrevChars, 0)];
            [glyphPath appendPath:pathOfChar];
            CGPathRelease(glyphCGPath);
        }
        
        // Free our buffers
        free(characters);
        free(glyphs);
        CFRelease(iFont);
        
        [[UIFont sharedPathCache] setObject:glyphPath forKey:key];
    }
    return [glyphPath copy];
}
@end
