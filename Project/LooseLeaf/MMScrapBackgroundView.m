//
//  MMScrapBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBackgroundView.h"

@implementation MMScrapBackgroundView{
    UIImageView* backingContentView;
}

@synthesize backingContentView;
@synthesize backgroundRotation;
@synthesize backgroundScale;
@synthesize backgroundOffset;
@synthesize backingViewHasChanged;

-(id) init{
    if(self = [super initWithFrame:CGRectZero]){
        backingContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        backingContentView.clipsToBounds = YES;
        [self addSubview:backingContentView];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    if(!backingContentView.image){
        // if the backingContentView has an image, then
        // it's frame is already set for its image size
        backingContentView.frame = self.bounds;
    }
}

-(void) updateBackingImageLocation{
    self.backingContentView.center = CGPointMake(self.bounds.size.width/2 + self.backgroundOffset.x,
                                                               self.bounds.size.height/2 + self.backgroundOffset.y);
    self.backingContentView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(self.backgroundRotation),CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale));
    self.backingViewHasChanged = YES;
}

#pragma mark - Properties

-(void) setBackingImage:(UIImage*)img{
    backingContentView.image = img;
    CGRect r = backingContentView.bounds;
    r.size = CGSizeMake(img.size.width, img.size.height);
    // must set the bounds, because the image view
    // has a transform applied, and setting the frame
    // will try to take that transform into account.
    //
    // instead, we want to change the pre-transform size
    backingContentView.bounds = r;
    [self updateBackingImageLocation];
}

-(void) setBackgroundRotation:(CGFloat)_backgroundRotation{
    backgroundRotation = _backgroundRotation;
    [self updateBackingImageLocation];
}

-(void) setBackgroundScale:(CGFloat)_backgroundScale{
    backgroundScale = _backgroundScale;
    [self updateBackingImageLocation];
}

-(void) setBackgroundOffset:(CGPoint)bgOffset{
    backgroundOffset = bgOffset;
    [self updateBackingImageLocation];
}

@end
