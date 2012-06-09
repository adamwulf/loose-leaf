//
//  SLPaperView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLPaperView : UIView{
    CGFloat scale;
}

@property (nonatomic, assign) CGFloat scale;

-(void) setScale:(CGFloat)_scale atLocation:(CGPoint)locationInView;

@end
