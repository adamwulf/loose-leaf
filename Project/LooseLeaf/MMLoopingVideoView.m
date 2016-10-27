//
//  MMLoopingVideoView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMLoopingVideoView.h"
#import "NSThread+BlockAdditions.h"
#import "UIColor+Shadow.h"
#import <AVFoundation/AVFoundation.h>
#import "MMTutorialManager.h"
#import "NSURL+UTI.h"


@implementation MMLoopingVideoView {
    NSURL* videoURL;

    UIView* videoHolder;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
    id rateObserver;
    id timeObserver;
}

+ (BOOL)supportsURL:(NSURL*)url {
    NSString* uti = [url universalTypeID];
    return UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeVideo) ||
        UTTypeConformsTo((__bridge CFStringRef)(uti), kUTTypeMovie);
}

- (id)initForVideo:(NSURL*)_videoURL withFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

- (void)didBecomeActive {
    if (avPlayer) {
        [avPlayer play];
    }
}

- (BOOL)isAnimating {
    // return true if the player is playing
    // from http://stackoverflow.com/questions/5655864/check-play-state-of-avplayer
    return (avPlayer.rate > 0 && !avPlayer.error);
}

- (BOOL)isBuffered {
    return avPlayer != nil;
}

- (void)startAnimating {
    if (![self isAnimating]) {
        if (!avPlayer) {
            avPlayer = [AVPlayer playerWithURL:videoURL];
            avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
            avPlayerLayer.frame = self.layer.bounds;
            [videoHolder.layer addSublayer:avPlayerLayer];
            avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }
        [avPlayer play];
    }
}

- (void)pauseAnimating {
    if ([self isAnimating]) {
        [avPlayer pause];
    }
}

- (void)stopAnimating {
    if ([self isBuffered]) {
        [avPlayerLayer removeFromSuperlayer];
        avPlayerLayer = nil;
        [avPlayer pause];
        [avPlayer removeTimeObserver:rateObserver];
        avPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)playerItemDidReachEnd:(NSNotification*)notification {
    AVPlayerItem* p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)dealloc {
    [self stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
