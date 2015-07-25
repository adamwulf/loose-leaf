//
//  MMVideoLoopView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMVideoLoopView.h"
#import "NSThread+BlockAdditions.h"
#import "UIColor+Shadow.h"
#import <AVFoundation/AVFoundation.h>
#import "MMTutorialManager.h"
#import "NSURL+UTI.h"

@implementation MMVideoLoopView{
    NSURL* videoURL;
    
    UIView* videoHolder;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
    id rateObserver;
    id timeObserver;
}

+(BOOL) supportsURL:(NSURL*)url{
    NSString* uti = [url universalTypeID];
    return UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeVideo) ||
        UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeMovie);
}

-(id) initForVideo:(NSURL*)_videoURL withTitle:(NSString*)_title forTutorialId:(NSString*)_tutorialId{
    if(self = [super initWithTitle:_title forTutorialId:_tutorialId]){
        videoURL = _videoURL;
        
        self.backgroundColor = [UIColor whiteColor];

        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:imageView atIndex:0];
        
        videoHolder = [[UIView alloc] initWithFrame:self.bounds];
        videoHolder.backgroundColor = [UIColor clearColor];
        [self insertSubview:videoHolder atIndex:1];

        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        UIImage* image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
        imageView.image = image;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
        


    }
    return self;
}

-(void) didBecomeActive{
    if(avPlayer){
        [avPlayer play];
    }
}

-(BOOL) isAnimating{
    // return true if the player is playing
    // from http://stackoverflow.com/questions/5655864/check-play-state-of-avplayer
    return (avPlayer.rate > 0 && !avPlayer.error);
}

-(BOOL) isBuffered{
    return avPlayer != nil;
}

-(void) startAnimating{
    if(![self isAnimating]){
        [self itemDidFinishPlaying:nil];
        if(!avPlayer){
            avPlayer = [AVPlayer playerWithURL:videoURL];
            avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
            avPlayerLayer.frame = self.layer.bounds;
            [videoHolder.layer addSublayer: avPlayerLayer];
            avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(itemDidFinishPlaying:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:avPlayer.currentItem];

            
            __weak AVPlayer* weakPlayer = avPlayer;
            __weak MMVideoLoopView* weakSelf = self;
            rateObserver = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.015, 100)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
                                                                 CGFloat currTime = CMTimeGetSeconds(weakPlayer.currentTime);
                                                                 CGFloat duration = CMTimeGetSeconds(weakPlayer.currentItem.duration);
                                                                 CGFloat percentDur = MAX(0, (currTime / duration));
                                                                 [weakSelf setDuration:percentDur];
                                                 }];
        }
        [avPlayer play];
    }
}

-(void) itemDidFinishPlaying:(NSNotification*) note{
    if(![[MMTutorialManager sharedInstance] hasCompletedStep:self.tutorialId]){
        NSLog(@"done playing!");
        [[MMTutorialManager sharedInstance] didCompleteStep:self.tutorialId];
        [self fadeDurationBar];
    }
}

-(BOOL) wantsNextButton{
    return YES;
}

-(void) pauseAnimating{
    if([self isAnimating]){
        [avPlayer pause];
    }
}

-(void) stopAnimating{
    if([self isBuffered]){
        [avPlayerLayer removeFromSuperlayer];
        avPlayerLayer = nil;
        [avPlayer pause];
        [avPlayer removeTimeObserver:rateObserver];
        avPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
