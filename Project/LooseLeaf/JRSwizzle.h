// JRSwizzle.h semver:1.0
//   Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/jrswizzle

#import <Foundation/Foundation.h>

@interface NSObject (ClippingBezierJRSwizzle)

+ (BOOL)mmcb_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)mmcb_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;

@end
