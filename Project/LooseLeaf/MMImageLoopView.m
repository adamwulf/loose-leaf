//
//  MMImageLoopView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMImageLoopView.h"
#import "NSURL+UTI.h"
#import "Constants.h"
#import "MMTutorialManager.h"

@implementation MMImageLoopView{
    BOOL isAnimating;
    NSTimer* timer;
}

-(id) initForImage:(NSURL*)imageURL withTitle:(NSString*)_title forTutorialId:(NSString*)_tutorialId{
    if(self = [super initWithTitle:_title forTutorialId:_tutorialId]){
        UIImage* img = [UIImage imageWithContentsOfFile:[imageURL path]];
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        imgView.image = img;
        [self insertSubview:imgView atIndex:0];
    }
    return self;
}

+(BOOL) supportsURL:(NSURL*)url{
    NSString* uti = [url universalTypeID];
    return UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeImage);
}

-(void) userFinishedImageTutorial{
    if(![[MMTutorialManager sharedInstance] hasCompletedStep:self.tutorialId]){
        [[MMTutorialManager sharedInstance] didCompleteStep:self.tutorialId];
    }
}

#pragma mark - MMLoopView

-(BOOL) wantsNextButton{
    return YES;
}

-(BOOL) isBuffered{
    return NO;
}

-(BOOL) isAnimating{
    return isAnimating;
}

-(void) startAnimating{
    isAnimating = YES;
    if(!timer){
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(userFinishedImageTutorial) userInfo:nil repeats:NO];
    }
}

-(void) pauseAnimating{
    [self stopAnimating];
}

-(void) stopAnimating{
    isAnimating = NO;
    [timer invalidate];
    timer = nil;
}

-(void) dealloc{
    [timer invalidate];
    timer = nil;
}

@end
