//
//  PaintableViewDelegate.h
//  PaintingSample
//
//  Created by Adam Wulf on 10/4/12.
//
//

#import <Foundation/Foundation.h>
#import "SLBackingStoreDelegate.h"

@class PaintView;

@protocol PaintableViewDelegate <NSObject>

-(void) didFlushPaintView:(PaintView*)paintView;

-(void) didLoadPaintView:(PaintView*)paintView;

-(NSArray*) paintableViewsAbove:(UIView*)aView;

-(BOOL) shouldDrawClipPath;

-(CGAffineTransform) transform;

@end
