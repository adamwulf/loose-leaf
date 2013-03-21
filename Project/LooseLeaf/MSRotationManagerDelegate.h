//
//  SLRotationManagerDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MSRotationManagerDelegate <NSObject>


-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didUpdateAccelerometerWithReading:(CGFloat)currentRawReading;

@end
