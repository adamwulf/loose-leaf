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

@implementation MMVideoLoopView{
    NSURL* videoURL;
    NSString* title;
    NSString* videoId;
    
    UIView* videoHolder;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
    id rateObserver;
    id timeObserver;
    
    
    
    UIView* durationBar;
}

-(id) initForVideo:(NSURL*)_videoURL withTitle:(NSString*)_title forVideoId:(NSString*)tutorialId{
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]){
        title = _title;
        videoURL = _videoURL;
        videoId = tutorialId;
        
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
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = _title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
        
        UILabel* durationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
        durationTitleLabel.backgroundColor = [UIColor clearColor];
        durationTitleLabel.textColor = [UIColor whiteColor];
        durationTitleLabel.text = _title;
        durationTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        durationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
        durationBar.clipsToBounds = YES;
        durationBar.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [durationBar addSubview:durationTitleLabel];
        [self addSubview:durationBar];

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

            
            CGFloat maxWidth = self.bounds.size.width;
            __weak UIView* weakDurationBar = durationBar;
            __weak AVPlayer* weakPlayer = avPlayer;
            NSString* _videoId = videoId;
            rateObserver = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.015, 100)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
                                                     CGFloat currTime = CMTimeGetSeconds(weakPlayer.currentTime);
                                                     CGFloat duration = CMTimeGetSeconds(weakPlayer.currentItem.duration);
                                                     CGRect fr = weakDurationBar.frame;
                                                     CGFloat percentDur = MAX(0, (currTime / duration));
                                                     fr.size.width = maxWidth * percentDur;
                                                     if(![[MMTutorialManager sharedInstance] hasCompletedStep:_videoId]){
                                                         weakDurationBar.frame = fr;
                                                     }
                                                 }];
        }
        [avPlayer play];
    }
}

-(void) itemDidFinishPlaying:(NSNotification*) note{
    if(![[MMTutorialManager sharedInstance] hasCompletedStep:videoId]){
        NSLog(@"done playing!");
        [[MMTutorialManager sharedInstance] didCompleteStep:videoId];
        [UIView animateWithDuration:.3 animations:^{
            durationBar.alpha = 0;
        }];
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
