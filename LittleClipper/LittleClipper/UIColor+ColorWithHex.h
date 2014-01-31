//
//  UIColor+ColorWithHex.h
//  ColorWithHex
//
//  Created by Angelo Villegas on 3/24/11.
//  Copyright (c) 2011 Angelo Villegas. All rights reserved.
//	http://www.studiovillegas.com/
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>


@interface UIColor (ColorWithHex)
// Convert hexadecimal value to RGB
+ (UIColor *)colorWithHex:(UInt32)hexadecimal;
+ (UIColor *)colorWithHexString:(NSString *)hexadecimal;

// Convert hexadecimal value to RGB
// format:
//	0x = Hexadecimal specifier (# for strings)
//	ff = alpha, ff = red, ff = green, ff = blue
+ (UIColor *)colorWithAlphaHex:(UInt32)hexadecimal;
+ (UIColor *)colorWithAlphaHexString:(NSString *)hexadecimal;

// Return the hexadecimal value of the RGB color specified.
+ (NSString *)colorWithRGBToHex:(UIColor *)color __attribute__((deprecated("Use 'hexStringFromColor:' instead.")));
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (NSString *)hexStringFromColor:(UIColor *)color hash:(BOOL)withHash;
+ (NSString *)hexStringWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

// Generates a color randomly
+ (UIColor *)randomColor;

// Some convenience methods to create colors
+ (UIColor *)oliveColor;				// 808000
+ (UIColor *)azureColor;				// F0FFFF
+ (UIColor *)orchidColor;				// DA70D6
+ (UIColor *)thistleColor;				// D8BFD8
+ (UIColor *)beigeColor;				// F5F5DC
+ (UIColor *)bananaColor;				// E3CF57
+ (UIColor *)plumColor;					// DDA0DD
+ (UIColor *)brickColor;				// 9C661F
+ (UIColor *)fireBrickColor;			// B22222
+ (UIColor *)skyBlueColor;				// 87CEEB
+ (UIColor *)khakiColor;				// F0E68C
+ (UIColor *)wheatColor;				// F5DEB3
+ (UIColor *)burlywoodColor;			// DEB887
+ (UIColor *)cadetBlueColor;			// 5F9EA0
+ (UIColor *)carrotColor;				// ED9121
+ (UIColor *)indigoColor;				// 4B0082
+ (UIColor *)maroonColor;				// 800000
+ (UIColor *)ceruleanColor;				// 007BA7
+ (UIColor *)moccasinColor;				// FFE4B5
+ (UIColor *)tanColor;					// D2B48C
+ (UIColor *)melonColor;				// E3A869
+ (UIColor *)cobaltColor;				// 3D59AB
+ (UIColor *)crimsonColor;				// DC143C
+ (UIColor *)mistyRoseColor;			// FFE4E1
+ (UIColor *)pinkColor;					// FFC0CB
+ (UIColor *)irisColor;					// 5A4FCF
+ (UIColor *)chartreuseColor;			// 7FFF00
+ (UIColor *)navyColor;					// 000080
+ (UIColor *)mintColor;					// BDFCC9
+ (UIColor *)tealColor;					// 008080
+ (UIColor *)violetColor;				// EE82EE
+ (UIColor *)limeColor;					// 32CD32
// Alloy Colors
+ (UIColor *)bronzeColor;				// CD7F32
+ (UIColor *)goldColor;					// FFD700
+ (UIColor *)silverColor;				// C0C0C0
// Gem Colors
+ (UIColor *)emeraldColor;				// 50C878
+ (UIColor *)rubyColor;					// E0115F
+ (UIColor *)sapphireColor;				// 082567
+ (UIColor *)aquamarineColor;			// 7FFFD4
+ (UIColor *)turquoiseColor;			// 40E0D0
// Dark Colors
+ (UIColor *)darkRedColor;				// 8B0000
+ (UIColor *)darkGreenColor;			// 006400
+ (UIColor *)darkBlueColor;				// 00008B
+ (UIColor *)darkCyanColor;				// 008B8B
+ (UIColor *)darkYellowColor;			// B5A42E
+ (UIColor *)darkMagentaColor;			// 8B008B
+ (UIColor *)darkOrangeColor;			// FF8C00
+ (UIColor *)darkVioletColor;			// 9400D3
// Light Colors
+ (UIColor *)lightRedColor;				// F26C4F
+ (UIColor *)lightGreenColor;			// 90EE90
+ (UIColor *)lightBlueColor;			// ADD8E6
+ (UIColor *)lightCyanColor;			// E0FFFF
+ (UIColor *)lightYellowColor;			// FFFFE0
+ (UIColor *)lightMagentaColor;			// FF77FF
+ (UIColor *)lightOrangeColor;			// E7B98A
+ (UIColor *)lightVioletColor;			// B98AE7

// ObjC (manual hex conversion to RGB)
+ (UIColor *)colorWithHexa:(NSString *)hexadecimal;

@end
