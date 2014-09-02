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
    if(!letter) return nil;
    
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
        
        CGSize advances[count];
        CTFontGetAdvancesForGlyphs(iFont, kCTFontOrientationHorizontal, glyphs, advances, count);
        for(int i=0;i<count;i++){
            // the character "1" is thin, but is given the same spacing in Helvetica-Nueue Bold
            // of the other numbers. This will thin out its spacing slightly
            if([[letter substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"]){
                advances[i].width = advances[i].width * 8 / 10.0;
            }
        }
        CGFloat xAdvance = 0;
        for(int i=0;i<count;i++){
            // Do something with the glyphs here, if a character is unmapped
            CGPathRef glyphCGPath = CTFontCreatePathForGlyph(iFont, glyphs[i], nil);
            UIBezierPath* pathOfChar = [UIBezierPath bezierPathWithCGPath:glyphCGPath];
            if([[letter substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"]){
                // we also move the character left a bit in its bounds
                // to remove some of its leading spacing too
                CGFloat oneXCorrection = -pathOfChar.bounds.origin.x * 1 / 5.0;
                [pathOfChar applyTransform:CGAffineTransformMakeTranslation(oneXCorrection, 0)];
            }
            [pathOfChar applyTransform:CGAffineTransformMakeTranslation(xAdvance, 0)];
            [glyphPath appendPath:pathOfChar];
            CGPathRelease(glyphCGPath);
            xAdvance += advances[i].width;
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
