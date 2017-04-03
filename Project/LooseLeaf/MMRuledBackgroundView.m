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

@implementation MMRuledBackgroundView{
    CGSize pageSize;
    CGSize originalSize;
}

#ifdef DEBUG

+(void) load{
    [[NSFileManager defaultManager] removeItemAtPath:[MMRuledBackgroundView cachePath] error:nil];
}

#endif

-(instancetype) initWithFrame:(CGRect)frame andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame]){
        NSValue* propSize = [properties objectForKey:@"originalSize"];
        originalSize = propSize ? [propSize CGSizeValue] : frame.size;
        pageSize = frame.size;
        
        CAShapeLayer* blueLines = [CAShapeLayer layer];
        blueLines.path = [[self pathForBlueLines] CGPath];
        blueLines.backgroundColor = [UIColor clearColor].CGColor;
        blueLines.strokeColor = [self lightBlue].CGColor;
        blueLines.fillColor = [UIColor clearColor].CGColor;
        
        [[self layer] addSublayer:blueLines];

        
        CAShapeLayer* redLines = [CAShapeLayer layer];
        redLines.path = [[self pathForRedLines] CGPath];
        redLines.backgroundColor = [UIColor clearColor].CGColor;
        redLines.strokeColor = [self lightRed].CGColor;
        redLines.fillColor = [UIColor clearColor].CGColor;
        
        [[self layer] addSublayer:redLines];

        // always scale from our top left
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.layer.position = CGPointMake(0, 0);
    }
    
    return self;
}

-(UIColor*)lightBlue{
    return [UIColor colorWithRed:16/255.0 green:178/255.0 blue:242/255.0 alpha:1.0];
}

-(UIColor*)lightRed{
    return [UIColor colorWithRed:238/255.0 green:91/255.0 blue:162/255.0 alpha:1.0];
}

-(CGPoint) scale{
    return CGPointMake(pageSize.width / originalSize.width, pageSize.height / originalSize.height);
}

-(UIBezierPath*) pathForBlueLines{
    
    CGFloat verticalSpacing = [UIDevice ppc] * .71 / [[UIScreen mainScreen] scale] * [self scale].y;
    CGFloat verticalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale] * [self scale].y;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat y = verticalMargin;
    while (y < pageSize.height) {
        [path moveToPoint:CGPointMake(0, y)];
        [path addLineToPoint:CGPointMake(pageSize.width, y)];
        y += verticalSpacing;
    }
    
    return path;
}

-(UIBezierPath*) pathForRedLines{
    CGFloat horizontalSpacing = [UIDevice ppc] * 3.2 / [[UIScreen mainScreen] scale] * [self scale].x;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(horizontalSpacing, 0)];
    [path addLineToPoint:CGPointMake(horizontalSpacing, pageSize.height)];
    [path moveToPoint:CGPointMake(horizontalSpacing + 2, 0)];
    [path addLineToPoint:CGPointMake(horizontalSpacing + 2, pageSize.height)];

    return path;
}


-(NSDictionary*) properties{
    return @{
             @"class" : NSStringFromClass([self class]),
             @"originalSize" : [NSValue valueWithCGSize:originalSize]
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
        CGPoint backgroundCenter = CGPointMake(originalSize.width / 2, originalSize.height / 2);
        CGPoint convertedC = [targetScrapState.contentView convertPoint:backgroundCenter fromView:self];
        
        CGSize backingImageSize = originalSize;
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

+(NSString*) cachePath{
    NSString* cacheDir = [[NSFileManager cachesPath] stringByAppendingPathComponent:@"defaultThumbnails"];
    [NSFileManager ensureDirectoryExistsAtPath:cacheDir];
    
    return [[cacheDir stringByAppendingString:NSStringFromClass([self class])] stringByAppendingPathExtension:@"png"];
}

-(void) drawInContext:(CGContextRef)context forSize:(CGSize)size{
    CGRect scaledScreen = CGSizeFill(originalSize, size);

    CGContextSaveThenRestoreForBlock(context, ^{
        // Scraps
        // adjust so that (0,0) is the origin of the content rect in the PDF page,
        // since the PDF may be much taller/wider than our screen
        CGContextScaleCTM(context, size.width / originalSize.width, size.height / originalSize.height);
        CGContextTranslateCTM(context, -scaledScreen.origin.x, -scaledScreen.origin.y);

        [[self lightBlue] setStroke];
        [[self pathForBlueLines] stroke];

        [[self lightRed] setStroke];
        [[self pathForRedLines] stroke];
    });
}

-(void) saveDefaultThumbToPath:(NSString*)path forSize:(CGSize)thumbSize{
    @autoreleasepool {
        if([[NSFileManager defaultManager] fileExistsAtPath:[MMRuledBackgroundView cachePath]]){
            [[NSFileManager defaultManager] copyItemAtPath:[MMRuledBackgroundView cachePath] toPath:path error:nil];
        }else{
            UIGraphicsBeginImageContext(thumbSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            [[UIColor whiteColor] setFill];
            CGContextFillRect(context, CGRectMake(0, 0, thumbSize.width, thumbSize.height));
            
            [self drawInContext:context forSize:thumbSize];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [UIImagePNGRepresentation(image) writeToFile:[MMRuledBackgroundView cachePath] atomically:YES];
            [[NSFileManager defaultManager] copyItemAtPath:[MMRuledBackgroundView cachePath] toPath:path error:nil];
        }
    }
}

@end
