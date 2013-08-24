//
//  MMScrappedPaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperView.h"


/**
 * the purpose of this subclass is to encompass all of the
 * scrap functionality for a page
 */
@interface MMScrappedPaperView : MMEditablePaperView

@property (readonly) NSArray* scraps;

// debug
-(void) beginShapeAtPoint:(CGPoint)point;
-(void) continueShapeAtPoint:(CGPoint)point;
-(void) finishShapeAtPoint:(CGPoint)point;
-(void) cancelShapeAtPoint:(CGPoint)point;


-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

@end
