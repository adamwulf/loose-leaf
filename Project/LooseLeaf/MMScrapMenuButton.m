//
//  MMScrapMenuButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapMenuButton.h"

@implementation MMScrapMenuButton{
    MMScrapView* scrap;
}

@synthesize scrap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setScrap:(MMScrapView *)_scrap{
    scrap = _scrap;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    UIBezierPath* path = [[scrap bezierPath] copy];
    
    // rotate the path
    [path applyTransform:CGAffineTransformMakeRotation(scrap.rotation)];

    // scale the path
    CGFloat scale = (self.bounds.size.width - 10) / MAX(path.bounds.size.width, path.bounds.size.height);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    [path applyTransform:scaleTransform];
    
    // now we need to center it in our view
    CGFloat targetX = (self.bounds.size.width - path.bounds.size.width) / 2;
    CGFloat targetY = (self.bounds.size.height - path.bounds.size.height) / 2;
    
    CGFloat transX = targetX - path.bounds.origin.x;
    CGFloat transY = targetY - path.bounds.origin.y;
    
    [path applyTransform:CGAffineTransformMakeTranslation(transX, transY)];
    
    
    [[UIColor whiteColor] setFill];
    [path fill];
    
    [[UIColor blackColor] setStroke];
    path.lineWidth = 1;
    [path stroke];
    
}


@end
