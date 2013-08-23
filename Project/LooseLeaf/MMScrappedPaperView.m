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

@implementation MMScrappedPaperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(void) addScrapWithPath:(UIBezierPath*)path{
    CGRect originalBounds = path.bounds;
    [path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x, -originalBounds.origin.y)];
    
    UIView* newScrap = [[UIView alloc] initWithFrame:originalBounds];
    newScrap.backgroundColor = [UIColor randomColor];
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path.CGPath];
    newScrap.layer.mask = maskLayer;
    newScrap.layer.borderColor = [UIColor redColor].CGColor;
    newScrap.layer.borderWidth = 1;
    [self.contentView addSubview:newScrap];
    
    NSLog(@"path: %@", path);
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
    
    for(UIBezierPath* shape in shapes){
        [self addScrapWithPath:[shape copy]];
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
