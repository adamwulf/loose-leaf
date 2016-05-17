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
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:self.backingImage
                                                                           forScrapState:targetScrapState];
    // clone the background so that the new scrap's
    // background aligns with the old scrap's background
    CGFloat orgRot = [self.delegate contextRotationForGenericBackground:self];
    CGFloat newRot = targetScrapState.delegate.rotation;
    CGFloat rotDiff = orgRot - newRot;
    
    CGPoint convertedC = [targetScrapState.contentView convertPoint:[self.delegate currentCenterOfBackgroundForGenericBackground:self] fromView:[self.delegate contextViewForGenericBackground:self]];
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
    
    
    CGSize contextSize = [self.delegate contextViewForGenericBackground:self].bounds.size;
    CGSize backingSize = _backingImage.size;
    CGSize targetSize = targetScrapState.originalSize;
    CGFloat targetRotation = backgroundView.backgroundRotation;
    CGFloat targetScale = backgroundView.backgroundScale;
    CGPoint targetOffset = backgroundView.backgroundOffset;
    
    double widthInt = 0;
    CGFloat widthFrac = modf(targetSize.width, &widthInt);
    targetSize.width += (1 - widthFrac);

    double heightInt = 0;
    CGFloat heightFrac = modf(targetSize.height, &heightInt);
    targetSize.height += (1 - heightFrac);
    
    UIGraphicsBeginImageContext(targetSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, targetSize.width, targetSize.height));
    
    CGAffineTransform scrapRotateAndScale = CGAffineTransformConcat(CGAffineTransformMakeRotation(targetRotation),CGAffineTransformMakeScale(targetScale, targetScale));
    CGAffineTransform backingRotateAndScale = CGAffineTransformConcat(CGAffineTransformMakeRotation(self.backgroundRotation),CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale));

//    CGContextTranslateCTM(context, contextSize.width/2, contextSize.height/2);
////    CGContextConcatCTM(context, backingRotateAndScale);
//
//    CGContextTranslateCTM(context, -contextSize.width/2+convertedC.x, -contextSize.height/2+convertedC.y);
    CGContextTranslateCTM(context, convertedC.x, convertedC.y);
    
    CGContextTranslateCTM(context, -4, -4);
    
    CGContextRotateCTM(context, targetRotation);

    CGContextScaleCTM(context, targetScale, targetScale);
    
    
//    CGContextConcatCTM(context, scrapRotateAndScale);

//    CGContextTranslateCTM(context, targetOffset.x, targetOffset.y);
//    CGContextTranslateCTM(context, -targetOffset.x, -targetOffset.y);
//    CGContextTranslateCTM(context, contextSize.width/2, contextSize.height/2);
    
    
//    CGContextTranslateCTM(context, targetOffset.x, targetOffset.y);
//    CGContextConcatCTM(context, scrapRotateAndScale);
    
    [self.backingImage drawInRect:CGRectMake(-backingSize.width/2, -backingSize.height/2, backingSize.width, backingSize.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backgroundView = [[MMScrapBackgroundView alloc] initWithImage:image forScrapState:targetScrapState];
    backgroundView.backgroundScale = 1.0;
    backgroundView.backgroundRotation = 0;
    backgroundView.backgroundOffset = CGPointZero;
    
    
    return backgroundView;
}


@end
