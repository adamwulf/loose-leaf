//
//  MMScrapBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBackgroundView.h"
#import "NSThread+BlockAdditions.h"

@implementation MMScrapBackgroundView{
    UIImageView* backingContentView;
    NSString* pathOfImageOnDisk;
}

@synthesize backingContentView;
@synthesize backgroundRotation;
@synthesize backgroundScale;
@synthesize backgroundOffset;
@synthesize backingViewHasChanged;

-(id) initWithImage:(UIImage*)img atPath:(NSString*)pathToSaveBackground{
    if(self = [super initWithFrame:CGRectZero]){
        pathOfImageOnDisk = pathToSaveBackground;
        backingContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        backingContentView.clipsToBounds = YES;
        backgroundScale = 1.0;
        [self addSubview:backingContentView];
        [self setBackingImage:img];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    if(!backingContentView.image){
        // if the backingContentView has an image, then
        // it's frame is already set for its image size
        backingContentView.bounds = self.bounds;
    }
    [self updateBackingImageLocation];
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

-(UIImage*) backingImage{
    return backingContentView.image;
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

#pragma mark - Save and Load

-(void) loadBackgroundFromDisk{
    if([[NSFileManager defaultManager] fileExistsAtPath:pathOfImageOnDisk]){
        //            NSLog(@"should be loading background");
        UIImage* image = [UIImage imageWithContentsOfFile:pathOfImageOnDisk];
        [NSThread performBlockOnMainThread:^{
            [self setBackingImage:image];
        }];
    }
}

-(void) saveBackgroundToDisk{
    if(self.backingViewHasChanged && ![[NSFileManager defaultManager] fileExistsAtPath:pathOfImageOnDisk]){
        if(self.backingContentView.image){
            NSLog(@"orientation: %d", (int) self.backingContentView.image.imageOrientation);
            [UIImageJPEGRepresentation(self.backingContentView.image, .9) writeToFile:pathOfImageOnDisk atomically:YES];
        }
        self.backingViewHasChanged = NO;
    }
}

@end
