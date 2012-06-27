//
//  UIFont+UIBezierCurve.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/25/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface UIFont (UIBezierCurve)

-(UIBezierPath*) bezierPathForString:(NSString*) letter;

@end
