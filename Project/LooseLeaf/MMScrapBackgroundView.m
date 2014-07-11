//
//  MMScrapBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBackgroundView.h"
#import "NSThread+BlockAdditions.h"
#import "MMScrapViewState.h"
#import "UIImage+Memory.h"
#import <DrawKit-iOS/DrawKit-iOS.h>

static int totalBackgroundBytes;

@implementation MMScrapBackgroundView{
    UIImageView* backingContentView;
    // the scrap that we're the background for
    __weak MMScrapViewState* scrapState;
    // cache our path
    NSString* backgroundPathCache;
}

+(int) totalBackgroundBytes{
    return totalBackgroundBytes;
}


@synthesize backingContentView;
@synthesize backgroundRotation;
@synthesize backgroundScale;
@synthesize backgroundOffset;
@synthesize backingViewHasChanged;

-(id) initWithImage:(UIImage*)img forScrapState:(MMScrapViewState*)_scrapState{
    if(self = [super initWithFrame:CGRectZero]){
        scrapState = _scrapState;
        backingContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        backingContentView.clipsToBounds = YES;
        backgroundScale = 1.0;
        [self addSubview:backingContentView];
        [self setBackingImage:img];
        if(img){
            @synchronized([MMScrapBackgroundView class]){
                totalBackgroundBytes += [img uncompressedByteSize];
            }
        }
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
    [self setNeedsDisplay];
}

#pragma mark - Properties

-(void) setBackingImage:(UIImage*)img{
    @synchronized([MMScrapBackgroundView class]){
        totalBackgroundBytes -= [backingContentView.image uncompressedByteSize];
        totalBackgroundBytes += [img uncompressedByteSize];
    }
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

#pragma mark - Path to the JPG on disk

-(NSString*) backgroundJPGFile{
    if(!backgroundPathCache){
        backgroundPathCache = [scrapState.pathForScrapAssets stringByAppendingPathComponent:[@"background" stringByAppendingPathExtension:@"jpg"]];
    }
    return backgroundPathCache;
}

-(NSString*) bundledBackgroundJPGFile{
    return [[MMScrapViewState bundledScrapDirectoryPathForUUID:scrapState.uuid andScrapsOnPaperState:scrapState.scrapsOnPaperState] stringByAppendingPathComponent:[@"background" stringByAppendingPathExtension:@"jpg"]];
}

#pragma mark - Duplication and Stamping

// returns an exact duplicate of this background, including all properties,
// and assigns it to the input scrap state
-(MMScrapBackgroundView*) duplicateFor:(MMScrapViewState*)otherScrapState{
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:self.backingImage
                                                                           forScrapState:otherScrapState];
    backgroundView.backgroundRotation = self.backgroundRotation;
    backgroundView.backgroundScale = self.backgroundScale;
    backgroundView.backgroundOffset = self.backgroundOffset;
    return backgroundView;
}

// this will create a copy of the current background and will align
// it onto the input scrap so that the new scrap's background perfectly
// aligns with this scrap's background
-(MMScrapBackgroundView*) stampBackgroundFor:(MMScrapViewState*)otherScrapState{
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:self.backingImage
                                                                           forScrapState:otherScrapState];
    // clone the background so that the new scrap's
    // background aligns with the old scrap's background
    CGFloat orgRot = scrapState.delegate.rotation;
    CGFloat newRot = otherScrapState.delegate.rotation;
    CGFloat rotDiff = orgRot - newRot;
    
    CGPoint orgC = scrapState.delegate.center;
    CGPoint newC = otherScrapState.delegate.center;
    CGPoint moveC = CGPointMake(newC.x - orgC.x, newC.y - orgC.y);
    
    CGPoint convertedC = [otherScrapState.contentView convertPoint:[scrapState currentCenterOfScrapBackground] fromView:scrapState.contentView];
    CGPoint refPoint = CGPointMake(otherScrapState.contentView.bounds.size.width/2,
                                   otherScrapState.contentView.bounds.size.height/2);
    CGPoint moveC2 = CGPointMake(convertedC.x - refPoint.x, convertedC.y - refPoint.y);
    
    // we have the correct adjustment value,
    // but now we need to account for the fact
    // that the new scrap has a different rotation
    // than the start scrap
    
    moveC = CGPointApplyAffineTransform(moveC, CGAffineTransformMakeRotation(scrapState.delegate.rotation - otherScrapState.delegate.rotation));
    
    backgroundView.backgroundRotation = self.backgroundRotation + rotDiff;
    backgroundView.backgroundScale = self.backgroundScale;
    backgroundView.backgroundOffset = moveC2;
    return backgroundView;
}

#pragma mark - Save and Load

-(void) loadBackgroundFromDiskWithProperties:(NSDictionary*)properties{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.backgroundJPGFile] ||
       [[NSFileManager defaultManager] fileExistsAtPath:self.bundledBackgroundJPGFile]){
        UIImage* image = [UIImage imageWithContentsOfFile:self.backgroundJPGFile];
        if(!image){
            image = [UIImage imageWithContentsOfFile:self.bundledBackgroundJPGFile];
        }
        [NSThread performBlockOnMainThread:^{
            [self setBackingImage:image];
        }];
    }
    self.backgroundRotation = [[properties objectForKey:@"backgroundRotation"] floatValue];
    self.backgroundScale = [[properties objectForKey:@"backgroundScale"] floatValue];
    self.backgroundOffset = CGPointMake([[properties objectForKey:@"backgroundOffset.x"] floatValue],
                                        [[properties objectForKey:@"backgroundOffset.y"] floatValue]);
}

// saves the backing image to disk if necessary, and
// returns an NSDictionary of the properties that should
// be persisted to disk
-(NSDictionary*) saveBackgroundToDisk{
    if(self.backingViewHasChanged && ![[NSFileManager defaultManager] fileExistsAtPath:self.backgroundJPGFile]){
        if([[NSFileManager defaultManager] fileExistsAtPath:self.bundledBackgroundJPGFile]){
            [[NSFileManager defaultManager] copyItemAtPath:self.bundledBackgroundJPGFile toPath:self.backgroundJPGFile error:nil];
        }else if(self.backingContentView.image){
            [UIImageJPEGRepresentation(self.backingContentView.image, .9) writeToFile:self.backgroundJPGFile atomically:YES];
        }
        self.backingViewHasChanged = NO;
    }
    
    NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
    [savedProperties setObject:[NSNumber numberWithFloat:self.backgroundRotation] forKey:@"backgroundRotation"];
    [savedProperties setObject:[NSNumber numberWithFloat:self.backgroundScale] forKey:@"backgroundScale"];
    [savedProperties setObject:[NSNumber numberWithFloat:self.backgroundOffset.x] forKey:@"backgroundOffset.x"];
    [savedProperties setObject:[NSNumber numberWithFloat:self.backgroundOffset.y] forKey:@"backgroundOffset.y"];
    return savedProperties;
}

#pragma mark - Dealloc

-(void) dealloc{
    @synchronized([MMScrapBackgroundView class]){
        totalBackgroundBytes -= [backingContentView.image uncompressedByteSize];
    }
}

//
// to support drawing on the view instead of transforming a subview,
// for instance drawing PDFs, then don't use the backingContentView
// at all, and uncomment this drawRect: call
//
//
//
//-(void) drawRect:(CGRect)rect{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//
//    // get the image
//    UIImage* img = self.backingContentView.image;
//
//    // center in the content bounds + offset
//    CGPoint moveCenterTo = CGPointMake(self.bounds.size.width/2 + self.backgroundOffset.x,
//                                       self.bounds.size.height/2 + self.backgroundOffset.y);
//    CGContextTranslateCTM(context, moveCenterTo.x, moveCenterTo.y);
//
//    // scale and rotate the image
//    CGContextConcatCTM(context, CGAffineTransformConcat(CGAffineTransformMakeRotation(self.backgroundRotation),
//                                                        CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale)));
//    
//    // draw the image, with 0,0 at the center
//    [img drawInRect:CGRectMake(-img.size.width/2, -img.size.height/2, img.size.width, img.size.height)];
//
//    // debug drawing
//    // dot the center
//    [[UIColor redColor] setFill];
//    [[UIBezierPath bezierPathWithArcCenter:CGPointZero radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES] fill];
//    // red border
//    UIBezierPath* redBorder = [UIBezierPath bezierPathWithRect:CGRectMake(-img.size.width/2, -img.size.height/2, img.size.width, img.size.height)];
//    redBorder.lineWidth = 20;
//    [[UIColor redColor] setStroke];
//    [redBorder stroke];
//
//    // restore
//    CGContextRestoreGState(context);
//}

@end
