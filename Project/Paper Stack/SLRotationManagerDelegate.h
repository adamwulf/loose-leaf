//
//  SLRotationManagerDelegate.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SLRotationManagerDelegate <NSObject>


-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didUpdateAccelerometerWithReading:(CGFloat)currentRawReading;

@end
