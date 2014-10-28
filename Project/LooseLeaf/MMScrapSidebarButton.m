//
//  MMScrapMenuButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapSidebarButton.h"

@implementation MMScrapSidebarButton{
    MMScrapView* scrap;
}

@synthesize scrap;
@synthesize rowNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+(CGFloat) scaleOfRowForScrap:(MMScrapView*)scrap forWidth:(CGFloat)width{
    CGFloat maxDim = MAX(scrap.frame.size.width, scrap.frame.size.height);
    return width / maxDim;
}

+(CGSize) sizeOfRowForScrap:(MMScrapView*)scrap forWidth:(CGFloat)width{
    CGFloat scale = [MMScrapSidebarButton scaleOfRowForScrap:scrap forWidth:width];
    CGSize s = CGSizeMake(scrap.frame.size.width * scale, scrap.frame.size.height*scale);
    if(s.width < s.height){
        s.width = s.height;
    }
    return s;
}

-(void) setScrap:(MMScrapView *)_scrap{
    scrap = _scrap;
    
    CGRect fr = self.frame;
    fr.size = [MMScrapSidebarButton sizeOfRowForScrap:scrap forWidth:self.bounds.size.width];
    self.frame = fr;
    
    // remove anything in our button
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // reset scrap to it's normal transform
    scrap.scale = scrap.scale;
    
    UIView* transformView = [[UIView alloc] initWithFrame:scrap.bounds];
    
    [transformView addSubview:scrap];
    scrap.center = transformView.center;
    
    [self addSubview:transformView];
    CGFloat scale = [MMScrapSidebarButton scaleOfRowForScrap:scrap forWidth:self.bounds.size.width];
    transformView.transform = CGAffineTransformMakeScale(scale, scale);
    transformView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

    [self addSubview:transformView];
    
    [self setNeedsDisplay];
}


#pragma mark - Touch Ownership

/**
 * these two methods make sure that this scrap container view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if([super hitTest:point withEvent:event]){
        return self;
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
}

@end
