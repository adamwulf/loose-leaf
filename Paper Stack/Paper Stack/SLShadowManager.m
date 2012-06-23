//
//  SLShadowManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import "SLShadowManager.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "NSThread+BlocksAdditions.h"

@implementation SLShadowManager


static SLShadowManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        shadowPathCache = [[NSMutableDictionary alloc] init];
        unitShadowPath = [[self generateUnitShadowPath] retain];
    }
    return _instance;
}

+(SLShadowManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLShadowManager alloc]init];
    }
    return _instance;
}


#pragma mark - shadow methods

-(UIBezierPath*) generateUnitShadowPath{
    UIBezierPath* path = [UIBezierPath bezierPath];
    [SLShadowManager sharedInstace];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    [path release];
    path = [[UIBezierPath bezierPath] retain];
    [path moveToPoint:CGPointMake((rand() % kShadowDepth) / width, (rand() % kShadowDepth) / height)];
    CGFloat loc = rand() % 100 / 100.0 / 20.0;
    // left
    while(loc < 1){
        CGFloat val = (rand() % 3) / width;
        [path addLineToPoint:CGPointMake(val, loc)];
        loc += rand() % 100 / 100.0 / 20.0;
    }
    // bottom
    loc = rand() % 100 / 100.0 / 20.0;
    while(loc < 1){
        [path addLineToPoint:CGPointMake(loc, 1 - (rand() % kShadowDepth) / height)];
        loc += rand() % 100 / 100.0 / 20.0;
    }
    // right
    loc = 1 - rand() % 100 / 100.0 / 20.0;
    while(loc > 0){
        [path addLineToPoint:CGPointMake(1 - (rand() % kShadowDepth)/width, loc)];
        loc -= rand() % 100 / 100.0 / 20.0;
    }
    // top
    loc = 1 - rand() % 100 / 100.0 / 20.0;
    while(loc > 0){
        [path addLineToPoint:CGPointMake(loc, (rand() % kShadowDepth) / height)];
        loc -= rand() % 100 / 100.0 / 20.0;
    }
    [path closePath];
    return path;
}



-(void) beginGeneratingShadows{
    if(![shadowPathCache count]){
        //
        // only run once
        [NSThread performBlockInBackground:^{
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGFloat minWidth = floorf(screenSize.width * kMinPageZoom);
            CGFloat maxWidth = screenSize.width * kMaxPageZoom;
            CGFloat currWidth = minWidth;
            CGFloat currHeight;
            NSDate* dt = [NSDate date];
            while(currWidth <= maxWidth){
                currHeight = currWidth / screenSize.width * screenSize.height;
                [self getShadowForSize:CGSizeMake(currWidth, currHeight)];
                currWidth += 1;
            }
            debug_NSLog(@"done with shadows: %f", -[dt timeIntervalSinceNow]);
        }];
    }
}

-(BOOL) hasShadowForSize:(CGSize)size{
    NSNumber* key = [NSNumber numberWithInt:(int) size.width];
    return [shadowPathCache objectForKey:key] && YES;
}

-(CGPathRef) getShadowForSize:(CGSize)size{
    NSNumber* key = [NSNumber numberWithInt:(int) size.width];
    UIBezierPath* path = [shadowPathCache objectForKey:key];
    if(!path){
        /*
        path = [[unitShadowPath copy] autorelease];
        [path applyTransform:CGAffineTransformMakeScale(size.width, size.height)];
         */
        path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
        [shadowPathCache setObject:path forKey:key];
    }
    return path.CGPath;
}

@end
