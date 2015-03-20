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

@implementation MMVideoLoopView{
    NSURL* videoURL;
    NSString* title;
    UIView* videoHolder;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
    id playerTimer;
    
    
    
    UIView* durationBar;
}

-(id) initForVideo:(NSURL*)_videoURL withTitle:(NSString*)_title{
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]){
        title = _title;
        videoURL = _videoURL;
        
        self.backgroundColor = [UIColor whiteColor];

        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        
        videoHolder = [[UIView alloc] initWithFrame:self.bounds];
        videoHolder.backgroundColor = [UIColor clearColor];
        [self addSubview:videoHolder];

        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        UIImage* image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
        imageView.image = image;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 50)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = _title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
        durationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
        durationBar.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [self addSubview:durationBar];
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
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
        if(!avPlayer){
            avPlayer = [AVPlayer playerWithURL:videoURL];
            avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
            avPlayerLayer.frame = self.layer.bounds;
            [videoHolder.layer addSublayer: avPlayerLayer];
            avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            CGFloat maxWidth = self.bounds.size.width;
            __weak UIView* weakDurationBar = durationBar;
            __weak AVPlayer* weakPlayer = avPlayer;
            playerTimer = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.015, 100)
                                                 queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                                                     CGFloat currTime = CMTimeGetSeconds(weakPlayer.currentTime);
                                                     CGFloat duration = CMTimeGetSeconds(weakPlayer.currentItem.duration);
                                                     CGRect fr = weakDurationBar.frame;
                                                     CGFloat percentDur = MAX(0, (currTime / duration));
                                                     fr.size.width = maxWidth * percentDur;
                                                     weakDurationBar.frame = fr;
                                                 }];
        }
        [avPlayer play];
    }
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
        [playerTimer removeTimeObserver:playerTimer];
        avPlayer = nil;
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
