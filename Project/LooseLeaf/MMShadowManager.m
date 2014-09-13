//
//  MMShadowManager.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMShadowManager.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "NSThread+BlockAdditions.h"

@implementation MMShadowManager


static MMShadowManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        shadowPathCache = [[NSMutableDictionary alloc] init];
        unitShadowPath = [self generateUnitShadowPath];
    }
    return _instance;
}

+(MMShadowManager*) sharedInstance{
    if(!_instance){
        _instance = [[MMShadowManager alloc]init];
    }
    return _instance;
}


#pragma mark - shadow methods

-(UIBezierPath*) generateUnitShadowPath{
    [MMShadowManager sharedInstance];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    UIBezierPath* path = [UIBezierPath bezierPath];
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
        // latest tests show this finishes in .02s on an iPad 3
        [NSThread performBlockInBackground:^{
            @autoreleasepool {
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                CGFloat minWidth = floorf(screenSize.width * kMinPageZoom);
                CGFloat maxWidth = screenSize.width * kMaxPageZoom;
                CGFloat currWidth = minWidth;
                CGFloat currHeight;
                while(currWidth <= maxWidth){
                    currHeight = currWidth / screenSize.width * screenSize.height;
                    [self getShadowForSize:CGSizeMake(currWidth, currHeight)];
                    currWidth += 1;
                }
            }
        }];
    }
}

-(BOOL) hasShadowForSize:(CGSize)size{
    NSNumber* key = [NSNumber numberWithInt:(int) size.width];
    return (BOOL)[shadowPathCache objectForKey:key];
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
