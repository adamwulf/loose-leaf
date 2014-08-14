//
//  MMOpenInAppSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInAppSidebarButton.h"
#import "MMShareManager.h"

@implementation MMOpenInAppSidebarButton{
    BOOL needsUpdate;
}

@synthesize indexPath;

- (id)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath*)_indexPath{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.indexPath = _indexPath;
    }
    return self;
}

-(void) setIndexPath:(NSIndexPath *)_indexPath{
    if(!indexPath ||
       indexPath.row != _indexPath.row ||
       indexPath.section != _indexPath.section){
        indexPath = _indexPath;
        [self setNeedsDisplay];
    }
    if(needsUpdate){
        [self setNeedsDisplay];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    UIView* view = [[MMShareManager sharedInstance] viewForIndexPath:self.indexPath];
    
    if(!view){
        needsUpdate = YES;
    }else{
        needsUpdate = NO;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [ovalPath addClip];
    [view drawViewHierarchyInRect:[self drawableFrame] afterScreenUpdates:NO];
    [[NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row] drawAtPoint:CGPointMake(20, 20) withAttributes:nil];
    CGContextRestoreGState(context);
    
    
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}

@end
