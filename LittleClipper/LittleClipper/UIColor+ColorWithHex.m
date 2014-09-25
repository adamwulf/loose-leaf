//
//  UIColor+ColorWithHex.m
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

#import "UIColor+ColorWithHex.h"


@implementation UIColor (ColorWithHex)

#pragma mark - Category Methods
// Direct Conversion to hexadecimal (Automatic)
+ (UIColor *)colorWithHex:(UInt32)hexadecimal
{
	CGFloat red, green, blue;
	
	// bitwise AND operation
	// hexadecimal's first 2 values
	red = ( hexadecimal >> 16 ) & 0xFF;
	// hexadecimal's 2 middle values
	green = ( hexadecimal >> 8 ) & 0xFF;
	// hexadecimal's last 2 values
	blue = hexadecimal & 0xFF;
	
	UIColor *color = [UIColor colorWithRed: red / 255.0f green: green / 255.0f blue: blue / 255.0f alpha: 1.0f];
	return color;
}

+ (UIColor *)colorWithAlphaHex:(UInt32)hexadecimal
{
	CGFloat red, green, blue, alpha;
	
	// bitwise AND operation
	// hexadecimal's first 2 values
	alpha = ( hexadecimal >> 24 ) & 0xFF;
	// hexadecimal's third and fourth values
	red = ( hexadecimal >> 16 ) & 0xFF;
	// hexadecimal's fifth and sixth values
	green = ( hexadecimal >> 8 ) & 0xFF;
	// hexadecimal's seventh and eighth
	blue = hexadecimal & 0xFF;
	
	UIColor *color = [UIColor colorWithRed: red / 255.0f green: green / 255.0f blue: blue / 255.0f alpha: alpha / 255.0f];
    return color;
}

+ (UIColor *)colorWithHexString:(NSString *)hexadecimal
{
	// convert Objective-C NSString to C string
	const char *cString = [hexadecimal cStringUsingEncoding: NSASCIIStringEncoding];
	long int hex;
	
	// if the string contains hash tag (#) then remove
	// hash tag and convert the C string to a base-16 int
	if ( cString[0] == '#' )
	{
		hex = strtol(cString + 1, NULL, 16);
	}
	else
	{
		hex = strtol(cString, NULL, 16);
	}
	
	UIColor *color = [self colorWithHex:(UInt32)hex];
	return color;
}

+ (UIColor *)colorWithAlphaHexString:(NSString *)hexadecimal
{
	const char *cString = [hexadecimal cStringUsingEncoding: NSASCIIStringEncoding];
	long long int hex;
	
	if ( cString[0] == '#' )
	{
		hex = strtoll( cString + 1 , NULL , 16 );
	}
	else
	{
		hex = strtoll( cString , NULL , 16 );
	}
	
	UIColor *color = [self colorWithAlphaHex: (UInt32) hex];
	return color;
}

// deprecated: Use 'hexStringFromColor:' instead.
+ (NSString *)colorWithRGBToHex:(UIColor *)color
{
	// Get the color components of the color
	const CGFloat *components = CGColorGetComponents( [color CGColor] );
	// Multiply it by 255 and display the result using an uppercase hexadecimal specifier (%X) with a character length of 2
	NSString *hexadecimal = [NSString stringWithFormat: @"#%02X%02X%02X" , (int)(255 * components[0]) , (int)(255 * components[1]) , (int)(255 * components[2])];
	
	return hexadecimal;
}
// deprecated

+ (NSString *)hexStringFromColor:(UIColor *)color
{
	NSString *string = [self hexStringFromColor: color hash: YES];
	return string;
}

+ (NSString *)hexStringFromColor:(UIColor *)color hash:(BOOL)withHash
{
	// get the color components of the color
	const NSUInteger totalComponents = CGColorGetNumberOfComponents( [color CGColor] );
	const CGFloat *components = CGColorGetComponents( [color CGColor] );
	NSString *hexadecimal = nil;
	
	// some cases, totalComponents will only have 2 components
	// such as black, white, gray, etc..
	// multiply it by 255 and display the result using an uppercase
	// hexadecimal specifier (%X) with a character length of 2
	switch ( totalComponents )
	{
		case 4 :
			hexadecimal = [NSString stringWithFormat: @"#%02X%02X%02X" , (int)(255 * components[0]) , (int)(255 * components[1]) , (int)(255 * components[2])];
			break;
			
		case 2 :
			hexadecimal = [NSString stringWithFormat: @"#%02X%02X%02X" , (int)(255 * components[0]) , (int)(255 * components[0]) , (int)(255 * components[0])];
			break;
			
		default:
			break;
	}
	
	return hexadecimal;
}

+ (NSString *)hexStringWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
	UIColor *color = [UIColor colorWithRed: red green: green blue: blue alpha: 1.0f];
	NSString *string = [self hexStringFromColor: color];
	return string;
}

+ (UIColor *)randomColor
{
	static BOOL generated = NO;
	
	// ff the randomColor hasn't been generated yet,
	// reset the time to generate another sequence
	if ( !generated )
	{
		generated = YES;
		srandom((int)time( NULL ) );
	}
	
	// generate a random number and divide it using the
	// maximum possible number random() can be generated
	CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
	
	UIColor *color = [UIColor colorWithRed: red green: green blue: blue alpha: 1.0f];
	return color;
}

#pragma mark - Convenience Methods
+ (UIColor *)oliveColor
{
	return [self colorWithHex: 0x808000];
}

+ (UIColor *)azureColor
{
	return [self colorWithHex: 0xF0FFFF];
}

+ (UIColor *)orchidColor
{
	return [self colorWithHex: 0xDA70D6];
}

+ (UIColor *)thistleColor
{
	return [self colorWithHex: 0xD8BFD8];
}

+ (UIColor *)beigeColor
{
	return [self colorWithHex: 0xF5F5DC];
}

+ (UIColor *)bananaColor
{
	return [self colorWithHex: 0xE3CF57];
}

+ (UIColor *)plumColor
{
	return [self colorWithHex: 0xDDA0DD];
}

+ (UIColor *)brickColor
{
	return [self colorWithHex: 0x9C661F];
}

+ (UIColor *)fireBrickColor
{
	return [self colorWithHex: 0xB22222];
}

+ (UIColor *)skyBlueColor
{
	return [self colorWithHex: 0x87CEEB];
}

+ (UIColor *)khakiColor
{
	return [self colorWithHex: 0xF0E68C];
}

+ (UIColor *)wheatColor
{
	return [self colorWithHex: 0xF5DEB3];
}

+ (UIColor *)burlywoodColor
{
	return [self colorWithHex: 0xDEB887];
}

+ (UIColor *)cadetBlueColor
{
	return [self colorWithHex: 0x5F9EA0];
}

+ (UIColor *)carrotColor
{
	return [self colorWithHex: 0xED9121];
}

+ (UIColor *)indigoColor
{
	return [self colorWithHex: 0x4B0082];
}

+ (UIColor *)maroonColor
{
	return [self colorWithHex: 0x800000];
}

+ (UIColor *)ceruleanColor
{
	return [self colorWithHex: 0x007BA7];
}

+ (UIColor *)moccasinColor
{
	return [self colorWithHex: 0xFFE4B5];
}

+ (UIColor *)tanColor
{
	return [self colorWithHex: 0xD2B48C];
}

+ (UIColor *)melonColor
{
	return [self colorWithHex: 0xE3A869];
}

+ (UIColor *)cobaltColor
{
	return [self colorWithHex: 0x3D59AB];
}

+ (UIColor *)crimsonColor
{
	return [self colorWithHex: 0xDC143C];
}

+ (UIColor *)mistyRoseColor
{
	return [self colorWithHex: 0xFFE4E1];
}

+ (UIColor *)pinkColor
{
	return [self colorWithHex: 0xFFC0CB];
}

+ (UIColor *)irisColor
{
	return [self colorWithHex: 0x5A4FCF];
}

+ (UIColor *)chartreuseColor
{
	return [self colorWithHex: 0x7FFF00];
}

+ (UIColor *)navyColor
{
	return [self colorWithHex: 0x000080];
}

+ (UIColor *)mintColor
{
	return [self colorWithHex: 0xBDFCC9];
}

+ (UIColor *)tealColor
{
	return [self colorWithHex: 0x008080];
}

+ (UIColor *)violetColor
{
	return [self colorWithHex: 0xEE82EE];
}

+ (UIColor *)limeColor
{
	return [self colorWithHex: 0x32CD32];
}

// Alloy Colors
+ (UIColor *)bronzeColor
{
	return [self colorWithHex: 0xCD7F32];
}

+ (UIColor *)goldColor
{
	return [self colorWithHex: 0xFFD700];
}

+ (UIColor *)silverColor
{
	return [self colorWithHex: 0xC0C0C0];
}

// Gem Colors
+ (UIColor *)emeraldColor
{
	return [self colorWithHex: 0x50C878];
}

+ (UIColor *)rubyColor
{
	return [self colorWithHex: 0xE0115F];
}

+ (UIColor *)sapphireColor
{
	return [self colorWithHex: 0x082567];
}

+ (UIColor *)aquamarineColor
{
	return [self colorWithHex: 0x7FFFD4];
}

+ (UIColor *)turquoiseColor
{
	return [self colorWithHex: 0x40E0D0];
}

// Dark Colors
+ (UIColor *)darkRedColor
{
	return [self colorWithHex: 0x8B0000];
}

+ (UIColor *)darkGreenColor
{
	return [self colorWithHex: 0x006400];
}

+ (UIColor *)darkBlueColor
{
	return [self colorWithHex: 0x00008B];
}

+ (UIColor *)darkCyanColor
{
	return [self colorWithHex: 0x008B8B];
}

+ (UIColor *)darkYellowColor
{
	return [self colorWithHex: 0xB5A42E];
}

+ (UIColor *)darkMagentaColor
{
	return [self colorWithHex: 0x8B008B];
}

+ (UIColor *)darkOrangeColor
{
	return [self colorWithHex: 0xFF8C00];
}

+ (UIColor *)darkVioletColor
{
	return [self colorWithHex: 0x9400D3];
}

// Light Colors
+ (UIColor *)lightRedColor
{
	return [self colorWithHex: 0xF26C4F];
}

+ (UIColor *)lightGreenColor
{
	return [self colorWithHex: 0x90EE90];
}

+ (UIColor *)lightBlueColor
{
	return [self colorWithHex: 0xADD8E6];
}

+ (UIColor *)lightCyanColor
{
	return [self colorWithHex: 0xE0FFFF];
}

+ (UIColor *)lightYellowColor
{
	return [self colorWithHex: 0xFFFFE0];
}

+ (UIColor *)lightMagentaColor
{
	return [self colorWithHex: 0xFF77FF];
}

+ (UIColor *)lightOrangeColor
{
	return [self colorWithHex: 0xE7B98A];
}

+ (UIColor *)lightVioletColor
{
	return [self colorWithHex: 0xB98AE7];
}

#pragma mark -
// you can delete this method. It only shows how to calculate and convert RGB color to Hexadecimal manually
// converting using Hex to RGB formula (Manual)
+ (UIColor *)colorWithHexa:(NSString *)hexadecimal
{
	// make sure that the hexadecimal value is in uppercase letters
	hexadecimal = [hexadecimal uppercaseString];
	NSInteger a;
	
	/*
	 If hexadecimal has a hash tag (#), remove it.
	 This purpose is solely for copy-pasting the whole hexadecimal
	 value that mostly consist of a hash-tag + the 6 characters
	 (e.i. #000000). Making sure that our little piece of software
	 will still accept the format with or without the hash tag.
	 */
	if ( [[hexadecimal substringWithRange: NSMakeRange( 0 , 1 )] isEqualToString: @"#"] )
	{
		a = 1;
	}
	else
	{
		a = 0;
	}
	
	/*
	 In hexadecimal, all numbers beyond 9 will be converted to single
	 character (Base16 digits should be converted beyond the digit 9)
	 Conversion:
	 10 = A	11 = B	12 = C	13 = D	14 = E	15 = F
	 */
	NSDictionary *hexConstants = @{ @"A" : @"10" , @"B" : @"11" , @"C" : @"12" , @"D" : @"13" , @"E" : @"14" , @"F" : @"15" };
	NSMutableArray *hexArray = [[NSMutableArray alloc] init];
	NSMutableArray *hexConverted = [[NSMutableArray alloc] init];
	
	// Separate all the characters
	for ( NSInteger x = a ; x < [hexadecimal length] ; x++ )
	{
		[hexArray insertObject: [hexadecimal substringWithRange: NSMakeRange( x , 1)] atIndex: x - 1];
	}
	
	// Convert the characters to their respective Base16 format
	for ( NSString *hexa in hexArray )
	{
		if ( [hexConstants valueForKey: hexa] )
		{
			[hexConverted addObject: [hexConstants valueForKey: hexa]];
		}
		else
		{
			[hexConverted addObject: hexa];
		}
	}
	
	CGFloat red = 0.0;
	CGFloat green = 0.0;
	CGFloat blue = 0.0;
	
	/*
	 Calculation of Hex to RGB :	# x y x' y' x" y"
	 x  * 16 = (x ) + y  = R
	 x' * 16 = (x') + y' = G
	 x" * 16 = (x") + y" = B
	 */
	for ( NSInteger x = 0 ; x < [hexConverted count] ; x++ )
	{
		switch (x)
		{
			case 0 :
			{
				const int value = [hexConverted[x] intValue];
				red = value * 16 + [hexConverted[x + 1] integerValue];
				break;
			}
			case 2 :
			{
				const int value = [hexConverted[x] intValue];
				green = value * 16 + [hexConverted[x + 1] integerValue];
				break;
			}
			case 4 :
			{
				const int value = [hexConverted[x] intValue];
				blue = value * 16 + [hexConverted[x + 1] integerValue];
				break;
			}
			default:
				break;
		}
	}
	
	UIColor *color = [UIColor colorWithRed: red / 255.0f green: green / 255.0f blue: blue / 255.0f alpha: 1.0f];
	return color;
}

@end
