//
//  MMEmojiAsset.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiAsset.h"
#import "Constants.h"
#import <CoreText/CoreText.h>
#import <JotUI/JotUI.h>


@implementation MMEmojiAsset {
    NSString* _emoji;
    UIBezierPath* _path;
    NSString* _emojiName;
    CGSize _size;

    UIImage* _thumb;
}

- (instancetype)initWithEmoji:(NSString*)emoji andPath:(UIBezierPath*)path andName:(NSString*)emojiName andSize:(CGSize)size {
    if (self = [super init]) {
        _emoji = emoji;
        _emojiName = emojiName;
        _path = path;
        _size = size;
        _thumb = [self aspectThumbnailWithMaxPixelSize:256];

#ifdef DEBUG
        // write emojis to a downloads folder so we can confirm they're drawing correctly
        [UIImagePNGRepresentation([self aspectThumbnailWithMaxPixelSize:500])
            writeToFile:[NSString stringWithFormat:@"/Users/adamwulf/Downloads/%@.png", _emojiName]
             atomically:YES];
#endif
    }

    return self;
}

- (UIImage*)aspectRatioThumbnail {
    return _thumb;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxDim, maxDim), YES, 1.0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, maxDim, maxDim));

    // glyph path is inverted, so flip vertically
    CGAffineTransform flipY = CGAffineTransformMakeScale(1, -1);
    // glyph path may be offset on the x coord, and by the height (because it's flipped)
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, -maxDim);

    CGContextConcatCTM(context, flipY);
    CGContextConcatCTM(context, translate);

    UIFont* font = [UIFont fontWithName:@"AppleColorEmoji" size:400];
    CGRect boundingRect = [self boundingRectForString:_emoji withFont:font];
    CGFloat descender = (CGRectGetHeight(boundingRect) - CGRectGetWidth(boundingRect)) / 2.0;
    descender += CGRectGetMinX(boundingRect);

    CGFloat scale = maxDim / CGRectGetWidth(boundingRect);
    CGContextConcatCTM(context, CGAffineTransformMakeScale(scale, scale));
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(0, descender));

    CFStringRef string = (__bridge CFStringRef)_emoji;
    CTFontRef fontref = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);

    // Initialize the string, font, and context

    CFStringRef keys[] = {kCTFontAttributeName};
    CFTypeRef values[] = {fontref};

    CFDictionaryRef attributes =
        CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                           (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                           &kCFTypeDictionaryKeyCallBacks,
                           &kCFTypeDictionaryValueCallBacks);

    CFAttributedStringRef attrString =
        CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
    CFRelease(string);
    CFRelease(attributes);

    CTLineRef line = CTLineCreateWithAttributedString(attrString);

    // Set text position and draw the line into the graphics context
    CGContextSetTextPosition(context, 0.0, 0.0);
    CTLineDraw(line, context);
    CFRelease(line);


    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (NSURL*)fullResolutionURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"loose-leaf://shapes/%@.shape", _emojiName]];
}

- (CGSize)fullResolutionSize {
    return _size;
}

- (CGFloat)defaultRotation {
    return 0;
}

- (CGFloat)preferredImportMaxDim {
    CGSize s = [self fullResolutionSize];
    return MAX(s.width, s.height);
}

- (UIBezierPath*)fullResolutionPath {
    return [_path copy];
}


- (CGRect)boundingRectForString:(NSString*)letter withFont:(UIFont*)font {
    UniChar* characters;
    CGGlyph* glyphs;
    CFIndex count;

    CFStringRef iString = (__bridge CFStringRef)letter;

    CTFontRef iFont = CTFontCreateWithName((__bridge CFStringRef)[font fontName], [font pointSize], NULL);

    assert(iFont != NULL && iString != NULL);

    // Get our string length.
    count = CFStringGetLength(iString);

    // Allocate our buffers for characters and glyphs.
    characters = (UniChar*)malloc(sizeof(UniChar) * count);
    assert(characters != NULL);

    glyphs = (CGGlyph*)malloc(sizeof(CGGlyph) * count);
    assert(glyphs != NULL);

    // Get the characters from the string.
    CFStringGetCharacters(iString, CFRangeMake(0, count), characters);

    // Get the glyphs for the characters.
    CTFontGetGlyphsForCharacters(iFont, characters, glyphs, count);

    CGRect rects[1];
    CGRect boundingRect = CTFontGetBoundingRectsForGlyphs(iFont, kCTFontOrientationHorizontal, glyphs, rects, 1);
    CGRect opticalRect = CTFontGetOpticalBoundsForGlyphs(iFont, glyphs, rects, 1, 0);
    opticalRect.origin.x = boundingRect.origin.x;

    // Free our buffers
    free(characters);
    free(glyphs);
    CFRelease(iFont);

    return opticalRect;
}


@end
