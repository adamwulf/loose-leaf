//
//  MMVideoLoopView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMVideoLoopView.h"
#import "NSThread+BlockAdditions.h"
#import <AVFoundation/AVFoundation.h>

@implementation MMVideoLoopView{
    NSURL* videoURL;
    NSString* title;
    UIView* videoHolder;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
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
    }
    return self;
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
        }
        [avPlayer play];
        NSLog(@"tutorial: %@ startAnimating", title);
    }
}

-(void) pauseAnimating{
    if([self isAnimating]){
        [avPlayer pause];
        NSLog(@"tutorial: %@ paused", title);
    }
}

-(void) stopAnimating{
    if([self isBuffered]){
        [avPlayerLayer removeFromSuperlayer];
        avPlayerLayer = nil;
        [avPlayer pause];
        avPlayer = nil;
        
        NSLog(@"tutorial: %@ stopAnimating", title);
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
