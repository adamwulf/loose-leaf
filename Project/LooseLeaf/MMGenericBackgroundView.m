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

-(id) initWithImage:(UIImage*)img andDelegate:(NSObject<MMGenericBackgroundViewDelegate>*)delegate{
    if(self = [super initWithFrame:CGRectZero]){
        [self setBackingImage:img];
        [self setDelegate:delegate];
        self.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    }
    return self;
}

// scale the image so that it would be aspectFill
-(void) aspectFillBackgroundImageIntoView{
    CGFloat horizontalRatio = self.bounds.size.width / self.backingImage.size.width;
    CGFloat verticalRatio = self.bounds.size.height / self.backingImage.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    [self setBackgroundScale:ratio];
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
    @autoreleasepool {
        // Find the relative rotation of the target scrap vs us
        CGFloat orgRot = [self.delegate contextRotationForGenericBackground:self];
        CGFloat newRot = targetScrapState.delegate.rotation;
        CGFloat rotDiff = orgRot - newRot;
        
        // also calculate its center vs our center
        CGPoint convertedC = [targetScrapState.contentView convertPoint:[self.delegate currentCenterOfBackgroundForGenericBackground:self] fromView:[self.delegate contextViewForGenericBackground:self]];
        
        CGSize backingImageSize = _backingImage.size;
        CGSize targetImageSize = targetScrapState.originalSize;
        CGFloat targetRotation = self.backgroundRotation + rotDiff;
        CGFloat targetScale = self.backgroundScale;
        
        // our target image size may not be on an exact pixel boundary
        // since its based off of the target scrap's bezier path's
        // bounding box. Let's round up to the nearest point.
        double widthInt = 0;
        CGFloat widthFrac = modf(targetImageSize.width, &widthInt);
        targetImageSize.width += (1 - widthFrac);
        
        double heightInt = 0;
        CGFloat heightFrac = modf(targetImageSize.height, &heightInt);
        targetImageSize.height += (1 - heightFrac);
        
        UIGraphicsBeginImageContextWithOptions(targetImageSize, NO, [[UIScreen mainScreen] scale]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor whiteColor] setFill];
        CGContextFillRect(context, CGRectMake(0, 0, targetImageSize.width, targetImageSize.height));
        
        // translate into the center of the context
        CGContextTranslateCTM(context, convertedC.x, convertedC.y);
        
        // No idea currently why i need this offset. There must be an offset somewhere
        // for scraps that I'm not remembering, but I'm not finding it.
        CGContextTranslateCTM(context, -4, -4);
        
        // rotate to match our target scrap orientation
        CGContextRotateCTM(context, targetRotation);
        
        // match our target scrap scale
        CGContextScaleCTM(context, targetScale, targetScale);
        
        // now draw the image centered at our current point
        [self.backingImage drawInRect:CGRectMake(-backingImageSize.width/2, -backingImageSize.height/2, backingImageSize.width, backingImageSize.height)];
        
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:image forScrapState:targetScrapState];
        backgroundView.backgroundScale = 1.0;
        backgroundView.backgroundRotation = 0;
        backgroundView.backgroundOffset = CGPointZero;
        
        return backgroundView;
    }
}


@end
