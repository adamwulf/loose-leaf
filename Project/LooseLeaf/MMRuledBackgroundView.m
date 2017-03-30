//
//  MMRuledBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMRuledBackgroundView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMRuledBackgroundView

-(instancetype) initWithFrame:(CGRect)frame andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame]){
        
        CAShapeLayer* shape = [CAShapeLayer layer];
        shape.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 200, 300, 400)] CGPath];
        shape.backgroundColor = [UIColor clearColor].CGColor;
        shape.fillColor = [UIColor lightGrayColor].CGColor;
        
        [[self layer] addSublayer:shape];

        // always scale from our top left
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.layer.position = CGPointMake(0, 0);
    }
    
    return self;
}

-(NSDictionary*) properties{
    return @{
             @"class" : NSStringFromClass([self class])
             };
}

// this will create a copy of the current background and will align
// it onto the input scrap so that the new scrap's background perfectly
// aligns with this scrap's background
//
// It's admittedly a bit ugly to be returning a subclass here. I'll need to
// refactor this in the future so that scraps contain a generic background
// instead of a specific subclass of background. same for pages.
- (MMScrapBackgroundView*)stampBackgroundFor:(MMScrapViewState*)targetScrapState {
    @autoreleasepool {
        // Find the relative rotation of the target scrap vs us
        CGFloat orgRot = 0;
        CGFloat newRot = targetScrapState.delegate.rotation;
        CGFloat rotDiff = orgRot - newRot;
        
        // also calculate its center vs our center
        CGPoint backgroundCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGPoint convertedC = [targetScrapState.contentView convertPoint:backgroundCenter fromView:self];
        
        CGSize backingImageSize = self.bounds.size;
        CGSize targetImageSize = targetScrapState.originalSize;
        CGFloat targetRotation = rotDiff;
        CGFloat targetScale = 1;
        
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
        [self drawViewHierarchyInRect:CGRectMake(-backingImageSize.width / 2, -backingImageSize.height / 2, backingImageSize.width, backingImageSize.height) afterScreenUpdates:NO];
        
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:image forScrapState:targetScrapState];
        backgroundView.backgroundScale = 1.0;
        backgroundView.backgroundRotation = 0;
        backgroundView.backgroundOffset = CGPointZero;
        
        return backgroundView;
    }
}

-(NSString*) cachePath{
    NSString* cacheDir = [[NSFileManager cachesPath] stringByAppendingPathComponent:@"defaultThumbnails"];
    [NSFileManager ensureDirectoryExistsAtPath:cacheDir];
    
    return [[cacheDir stringByAppendingString:NSStringFromClass([self class])] stringByAppendingPathExtension:@"png"];
}

-(void) drawInContext:(CGContextRef)context forSize:(CGSize)size{
    CGRect scaledScreen = CGSizeFill(self.bounds.size, size);

    UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 200, 300, 400)];
    CGContextSaveThenRestoreForBlock(context, ^{
        // Scraps
        // adjust so that (0,0) is the origin of the content rect in the PDF page,
        // since the PDF may be much taller/wider than our screen
        CGContextScaleCTM(context, size.width / self.bounds.size.width, size.height / self.bounds.size.height);
        CGContextTranslateCTM(context, -scaledScreen.origin.x, -scaledScreen.origin.y);

        [[UIColor lightGrayColor] setFill];
        [path fill];
    });
}

-(void) saveDefaultThumbToPath:(NSString*)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:[self cachePath]]){
        [[NSFileManager defaultManager] copyItemAtPath:[self cachePath] toPath:path error:nil];
    }else{
        // need to generate the thumbnail
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* img = [self mp_snapshotImage];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                [UIImagePNGRepresentation(img) writeToFile:[self cachePath] atomically:YES];
                [[NSFileManager defaultManager] copyItemAtPath:[self cachePath] toPath:path error:nil];
            });
        });
    }
}

@end
