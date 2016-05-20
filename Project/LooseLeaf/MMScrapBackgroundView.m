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
#import "Constants.h"

static int totalBackgroundBytes;

@interface MMScrapBackgroundView ()<MMGenericBackgroundViewDelegate>

@end

@implementation MMScrapBackgroundView{
    // the scrap that we're the background for
    __weak MMScrapViewState* scrapState;
    // cache our path
    NSString* backgroundPathCache;
}

+(int) totalBackgroundBytes{
    return totalBackgroundBytes;
}

-(id) initWithImage:(UIImage*)img forScrapState:(MMScrapViewState*)_scrapState{
    if(self = [super initWithImage:img andDelegate:self]){
        scrapState = _scrapState;
        _backingContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        _backingContentView.clipsToBounds = YES;
        [self setBackgroundScale:1.0];
        [self setBackingImage:img];
        [self addSubview:_backingContentView];
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
    if(!_backingContentView.image){
        // if the backingContentView has an image, then
        // it's frame is already set for its image size
        _backingContentView.bounds = self.bounds;
    }
    [self updateBackingImageLocation];
}

-(void) updateBackingImageLocation{
    CheckMainThread;
    self.backingContentView.center = CGPointMake(self.bounds.size.width/2 + self.backgroundOffset.x,
                                                               self.bounds.size.height/2 + self.backgroundOffset.y);
    self.backingContentView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(self.backgroundRotation),CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale));
    self.backingViewHasChanged = YES;
}

#pragma mark - Properties

-(void) setBackingImage:(UIImage*)img{
    CheckMainThread;
    [super setBackingImage:img];
    @synchronized([MMScrapBackgroundView class]){
        totalBackgroundBytes -= [_backingContentView.image uncompressedByteSize];
        totalBackgroundBytes += [img uncompressedByteSize];
    }
    _backingContentView.image = img;
    CGRect r = _backingContentView.bounds;
    r.size = CGSizeMake(img.size.width, img.size.height);
    // must set the bounds, because the image view
    // has a transform applied, and setting the frame
    // will try to take that transform into account.
    //
    // instead, we want to change the pre-transform size
    _backingContentView.bounds = r;
    [self updateBackingImageLocation];
}

-(void) setBackgroundRotation:(CGFloat)_backgroundRotation{
    [super setBackgroundRotation:_backgroundRotation];
    [self updateBackingImageLocation];
}

-(void) setBackgroundScale:(CGFloat)_backgroundScale{
    [super setBackgroundScale:_backgroundScale];
    [self updateBackingImageLocation];
}

-(void) setBackgroundOffset:(CGPoint)bgOffset{
    [super setBackgroundOffset:bgOffset];
    [self updateBackingImageLocation];
}

#pragma mark - MMGenericBackgroundViewDelegate

// The background object lives in some parent view space.
// so these properties are how we relate to that parent view space

// the context that our scrap lives in
-(UIView*) contextViewForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return scrapState.contentView;
}

// the rotation of the scrap relative to the contextView (the page)
// (vs self.backgroundRotation, which is the rotation of the
//  background relative to the scrap)
-(CGFloat) contextRotationForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return scrapState.delegate.rotation;
}

// the center of the background relative to the contextView (the page)
-(CGPoint) currentCenterOfBackgroundForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return [scrapState currentCenterOfScrapBackground];
}

#pragma mark - Path to the JPG on disk

-(NSString*) backgroundJPGFile{
    if(!backgroundPathCache){
        backgroundPathCache = [scrapState.pathForScrapAssets stringByAppendingPathComponent:[@"background" stringByAppendingPathExtension:@"jpg"]];
    }
    return backgroundPathCache;
}

-(NSString*) bundledBackgroundJPGFile{
    return [[scrapState.scrapsOnPaperState bundledDirectoryPathForScrapUUID:scrapState.uuid] stringByAppendingPathComponent:[@"background" stringByAppendingPathExtension:@"jpg"]];
}

#pragma mark - Duplication and Stamping

// returns an exact duplicate of this background, including all properties,
// and assigns it to the input scrap state
-(MMScrapBackgroundView*) duplicateFor:(MMScrapViewState*)otherScrapState{
    // we need to swap the image out for another one, because the source image
    // might be deleted from disk soon. so this image needs to load
    // from its own assets
    UIImage* replacementImage = [UIImage imageWithData:UIImagePNGRepresentation(self.backingImage)];
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:replacementImage
                                                                           forScrapState:otherScrapState];
    backgroundView.backgroundRotation = self.backgroundRotation;
    backgroundView.backgroundScale = self.backgroundScale;
    backgroundView.backgroundOffset = self.backgroundOffset;
    return backgroundView;
}

#pragma mark - Save and Load

-(void) loadBackgroundFromDiskWithProperties:(NSDictionary*)properties{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.backgroundJPGFile] ||
       [[NSFileManager defaultManager] fileExistsAtPath:self.bundledBackgroundJPGFile]){
        NSData* imageData = [NSData dataWithContentsOfFile:self.backgroundJPGFile];
        if(!imageData){
            DebugLog(@"can't get background!");
            imageData = [NSData dataWithContentsOfFile:self.bundledBackgroundJPGFile];
            if(!imageData){
                DebugLog(@"can't get background!");
            }
        }
        UIImage* image = [UIImage imageWithData:imageData];
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
        totalBackgroundBytes -= [_backingContentView.image uncompressedByteSize];
    }
}

@end
