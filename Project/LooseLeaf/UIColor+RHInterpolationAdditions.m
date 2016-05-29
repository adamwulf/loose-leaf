//
//  UIColor+RHInterpolationAdditions.m
//
//  Created by Richard Heard on 10/03/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "UIColor+RHInterpolationAdditions.h"

@implementation UIColor (RHInterpolationAdditions)

static inline float interpolate(CGFloat a, CGFloat b, CGFloat fraction) {
    return (a + ((b - a) * fraction));
}

-(UIColor*)blendedColorWithFraction:(CGFloat)fraction ofColor:(UIColor*)endColor{
    if (fraction <= 0.0f) return self;
    if (fraction >= 1.0f) return endColor;


    CGFloat a1, b1, c1, d1 = 0.0f;
    CGFloat a2, b2, c2, d2 = 0.0f;
    
#define i(x) interpolate(x ## 1, x ## 2, fraction)

    //iOS5 +
    if ([UIColor instancesRespondToSelector:@selector(getWhite:alpha:)]){
        
        //white
        if ([self getWhite:&a1 alpha:&b1] && [endColor getWhite:&a2 alpha:&b2]){
            return [UIColor colorWithWhite:i(a) alpha:i(b)];
        }
        
        //RGB
        if ([self getRed:&a1 green:&b1 blue:&c1 alpha:&d1] && [endColor getRed:&a2 green:&b2 blue:&c2 alpha:&d2]){
            return [UIColor colorWithRed:i(a) green:i(b) blue:i(c) alpha:i(d)];
        }
        
        //HSB
        if ([self getHue:&a1 saturation:&b1 brightness:&c1 alpha:&d1] && [endColor getHue:&a2 saturation:&b2 brightness:&c2 alpha:&d2]){
            return [UIColor colorWithHue:i(a) saturation:i(b) brightness:i(c) alpha:i(d)];
        }
    } else if (self.CGColor && endColor.CGColor){
        //use the underlying CGColorRef
        
        NSInteger componentCount = CGColorGetNumberOfComponents(self.CGColor);
        
        if (componentCount == CGColorGetNumberOfComponents(endColor.CGColor)){
            //same number of components, we can interpolate
            
            const CGFloat *selfComponents = CGColorGetComponents(self.CGColor);
            const CGFloat *endComponents = CGColorGetComponents(endColor.CGColor);
            
            CGFloat *outComponents = calloc(sizeof(CGFloat), componentCount);
            
            for (int i = 0; i < componentCount ; i++){
                outComponents[i] = interpolate(selfComponents[i], endComponents[i], fraction);
            }
            
            CGColorRef newColorRef = CGColorCreate(CGColorGetColorSpace(self.CGColor), outComponents);
            UIColor *newColor = [UIColor colorWithCGColor:newColorRef];
            
            CGColorRelease(newColorRef);
            free(outComponents);
            
            return newColor;
        }
        
    }
    
    //error
    return nil;
}
      
@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassUICRHIA : NSObject @end @implementation RHFixCategoryBugClassUICRHIA @end

