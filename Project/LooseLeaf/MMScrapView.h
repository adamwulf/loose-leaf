//
//  MMScrap.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScrapView : UIView

@property (readonly) UIBezierPath* bezierPath;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) BOOL selected;

- (id)initWithBezierPath:(UIBezierPath*)path;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

-(BOOL) containsTouch:(UITouch*)touch;

/**
 * will return the array of touches that this scrap
 * contains, but only if more than one touch
 * will match
 */
-(NSSet*) matchingTouchesFrom:(NSSet*) touches;

#pragma mark - debug
-(UIBezierPath*) intersect:(UIBezierPath*)newPath;

@end
