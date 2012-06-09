//
//  SLPaperView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLPaperView

@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage* img = [UIImage imageNamed:@"space.jpeg"];
        UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
        imgView.frame = self.bounds;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        
        [self.layer setMasksToBounds:NO ];
        [self.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
        [self.layer setShadowOpacity:0.5 ];
        [self.layer setShadowRadius:2.0 ];
        [self.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
        [self.layer setShouldRasterize:YES ];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setScale:(CGFloat)_scale{
    [self setScale:_scale atLocation:self.center];
}

-(void) setScale:(CGFloat)_scale atLocation:(CGPoint)locationInView{
    scale = _scale;
    CGRect superBounds = self.superview.bounds;
    CGRect oldBounds = self.frame;
    CGRect newBounds = oldBounds;
    
    CGPoint normalizedLocation = CGPointMake(locationInView.x / oldBounds.size.width, locationInView.y / oldBounds.size.height);
    
    //
    // calculate the size of the scale
    CGSize newSizeOfView = CGSizeMake(superBounds.size.width * scale, superBounds.size.height * scale);
    newBounds.size = newSizeOfView;
    
    CGPoint newLocationInView = CGPointMake(normalizedLocation.x * newSizeOfView.width, normalizedLocation.y * newSizeOfView.height);
    
    CGPoint newOriginForBounds = CGPointMake(oldBounds.origin.x + (locationInView.x - newLocationInView.x), oldBounds.origin.y + (locationInView.y - newLocationInView.y));
    newBounds.origin = newOriginForBounds;
    
    
    self.frame = newBounds;
}

@end
