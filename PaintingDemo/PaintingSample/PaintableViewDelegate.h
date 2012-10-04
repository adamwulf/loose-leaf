//
//  PaintableViewDelegate.h
//  PaintingSample
//
//  Created by Adam Wulf on 10/4/12.
//
//

#import <Foundation/Foundation.h>

@protocol PaintableViewDelegate <NSObject>

-(NSArray*) paintableViewsAbove:(UIView*)aView;

-(BOOL) shouldDrawClipPath;

@end
