//
//  MMPaperTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMEmptyTemplateView.h"

@implementation MMPaperTemplateView

#ifdef DEBUG

+(void) load{
    [[NSFileManager defaultManager] removeItemAtPath:[MMPaperTemplateView cachePath] error:nil];
}

#endif

+(Class) backgroundClassForString:(NSString*)currentBackgroundStyle{
    Class backgroundClass = [MMEmptyTemplateView class];
    
    if([currentBackgroundStyle length]){
        backgroundClass = NSClassFromString(currentBackgroundStyle);
        if(![backgroundClass isSubclassOfClass:[MMPaperTemplateView class]]){
            backgroundClass = [MMEmptyTemplateView class];
        }
    }
    
    return backgroundClass;
}

+(MMPaperTemplateView*) viewForFrame:(CGRect)frame andProperties:(NSDictionary *)properties{
    Class backgroundClass = [MMPaperTemplateView backgroundClassForString:properties[@"class"]];
    
    return [[backgroundClass alloc] initWithFrame:frame andProperties:properties];
}

-(instancetype) initWithFrame:(CGRect)frame andOriginalSize:(CGSize)_originalSize andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame]){
        originalSize = _originalSize;
        pageSize = frame.size;
        pageSize = frame.size;
        
        [self finishBackgroundPaperViewInit];
    }
    
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame]){
        NSNumber* originalWidth = [properties objectForKey:@"originalSize.width"];
        NSNumber* originalHeight = [properties objectForKey:@"originalSize.height"];
        
        originalSize = originalWidth && originalHeight ? CGSizeMake([originalWidth doubleValue], [originalHeight doubleValue]) : frame.size;
        pageSize = frame.size;
        pageSize = frame.size;
        
        [self finishBackgroundPaperViewInit];
    }
    
    return self;
}

-(void) finishBackgroundPaperViewInit{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    // always scale from our top left
    self.layer.anchorPoint = CGPointMake(0, 0);
    self.layer.position = CGPointMake(0, 0);
}

-(CGPoint) scale{
    return CGPointMake(pageSize.width / originalSize.width, pageSize.height / originalSize.height);
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
        CGPoint backgroundCenter = CGPointMake(pageSize.width / 2, pageSize.height / 2);
        CGPoint convertedC = [targetScrapState.contentView convertPoint:backgroundCenter fromView:self];
        
        CGSize backingImageSize = pageSize;
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
    
    return [[cacheDir stringByAppendingPathComponent:NSStringFromClass([self class])] stringByAppendingPathExtension:@"png"];
}

-(void) saveDefaultThumbToPath:(NSString*)path forSize:(CGSize)thumbSize{
    @autoreleasepool {
        if([[NSFileManager defaultManager] fileExistsAtPath:[[self class] cachePath]]){
            [[NSFileManager defaultManager] copyItemAtPath:[[self class] cachePath] toPath:path error:nil];
        }else{
            UIGraphicsBeginImageContext(thumbSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            [[UIColor whiteColor] setFill];
            CGContextFillRect(context, CGRectMake(0, 0, thumbSize.width, thumbSize.height));
            
            [self drawInContext:context forSize:thumbSize];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [UIImagePNGRepresentation(image) writeToFile:[[self class] cachePath] atomically:YES];
            [[NSFileManager defaultManager] copyItemAtPath:[[self class] cachePath] toPath:path error:nil];
        }
    }
}

-(void) drawInContext:(CGContextRef)context forSize:(CGSize)size{
    @throw kAbstractMethodException;
}

@end
