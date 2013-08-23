//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "PolygonToolDelegate.h"
#import "UIColor+ColorWithHex.h"
#import "MMScrapView.h"

@implementation MMScrappedPaperView{
    NSMutableArray* scraps;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code
        scraps = [NSMutableArray array];
    }
    return self;
}


/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(void) addScrapWithPath:(UIBezierPath*)path{
    UIView* newScrap = [[MMScrapView alloc] initWithBezierPath:path];
    [scraps addObject:newScrap];
    [self.contentView insertSubview:newScrap belowSubview:polygonDebugView];
}


#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
    for(MMScrapView* scrap in scraps){
        [scrap didUpdateAccelerometerWithRawReading:-currentRawReading];
    }
}

#pragma mark - PolygonToolDelegate

-(void) beginShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    NSLog(@"begin");
    [polygonDebugView clear];
    
    [polygonDebugView addTouchPoint:point];
}

-(void) continueShapeAtPoint:(CGPoint)point{
    // noop for now
    // send touch event to the view that
    // will display the drawn polygon line
    [polygonDebugView addTouchPoint:point];
}

-(void) finishShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    //
    // and also process the touches into the new
    // scrap polygon shape, and add that shape
    // to the page
    NSLog(@"finish");
    [polygonDebugView addTouchPoint:point];
    NSArray* shapes = [polygonDebugView complete];
    
    [polygonDebugView clear];

    for(UIBezierPath* shape in shapes){
        if([scraps count]){
            [[scraps objectAtIndex:0] intersect:shape];
        }else{
            [self addScrapWithPath:[shape copy]];
        }
    }
    
}

-(void) cancelShapeAtPoint:(CGPoint)point{
    // we've cancelled the polygon (possibly b/c
    // it was a pan/pinch instead), so clear
    // the drawn polygon and reset.
    NSLog(@"cancel");
    [polygonDebugView clear];
}




@end
