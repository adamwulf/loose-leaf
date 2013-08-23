//
//  MMScrap.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScrapView : UIView

- (id)initWithBezierPath:(UIBezierPath*)path;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

@end
