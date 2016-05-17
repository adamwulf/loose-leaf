//
//  MMGenericBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMGenericBackgroundView.h"
#import "MMScrapBackgroundView.h"
#import "MMScrapViewState.h"

@implementation MMGenericBackgroundView

-(id) initWithImage:(UIImage*)img{
    if(self = [super initWithFrame:CGRectZero]){
        [self setBackingImage:img];
    }
    return self;
}

// scale the image so that it would be aspectFill
-(void) aspectFillBackgroundImageIntoView{
    CGFloat horizontalRatio = self.backingImage.size.width / self.bounds.size.width;
    CGFloat verticalRatio = self.backingImage.size.height / self.bounds.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    [self setBackgroundScale:ratio];
}

#pragma mark - Context Properties
// The background object lives in some parent view space.
// so these properties are how we relate to that parent view space

// the context that our scrap lives in
-(UIView*) contextView{
    return self.superview;
}

// the rotation of the scrap relative to the contextView (the page)
// (vs self.backgroundRotation, which is the rotation of the
//  background relative to the scrap)
-(CGFloat) contextRotation{
    return 0;
}

// the center of the background relative to the contextView (the page)
-(CGPoint) currentCenterOfBackground{
    return self.center;
}

#pragma mark - Public Methods

// this will create a copy of the current background and will align
// it onto the input scrap so that the new scrap's background perfectly
// aligns with this scrap's background
//
// It's admittedly a bit ugly to be returning a subclass here. I'll need to
// refactor this in the future so that scraps contain a generic background
// instead of a specific subclass of background. same for pages.
-(MMScrapBackgroundView*) stampBackgroundFor:(MMScrapViewState*)targetScrapState{
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:self.backingImage
                                                                           forScrapState:targetScrapState];
    // clone the background so that the new scrap's
    // background aligns with the old scrap's background
    CGFloat orgRot = [self contextRotation];
    CGFloat newRot = targetScrapState.delegate.rotation;
    CGFloat rotDiff = orgRot - newRot;
    
    CGPoint convertedC = [targetScrapState.contentView convertPoint:[self currentCenterOfBackground] fromView:[self contextView]];
    CGPoint refPoint = CGPointMake(targetScrapState.contentView.bounds.size.width/2,
                                   targetScrapState.contentView.bounds.size.height/2);
    CGPoint moveC2 = CGPointMake(convertedC.x - refPoint.x, convertedC.y - refPoint.y);
    
    // we have the correct adjustment value,
    // but now we need to account for the fact
    // that the new scrap has a different rotation
    // than the start scrap
    backgroundView.backgroundRotation = self.backgroundRotation + rotDiff;
    backgroundView.backgroundScale = self.backgroundScale;
    backgroundView.backgroundOffset = moveC2;
    return backgroundView;
}


@end
