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
    UIImageView* imageView;
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
}

-(id) initForVideo:(NSURL*)_videoURL{
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]){
        
        videoURL = _videoURL;
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];

        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        UIImage* image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
        imageView.image = image;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
    }
    return self;
}

-(BOOL) isAnimating{
    // return true if the player is playing
    // from http://stackoverflow.com/questions/5655864/check-play-state-of-avplayer
    return (avPlayer.rate > 0 && !avPlayer.error);
}

-(void) startAnimating{
    if(![self isAnimating]){
        [[NSThread mainThread] performBlock:^{
            imageView.hidden = YES;
        } afterDelay:.1];
        

        avPlayer = [AVPlayer playerWithURL:videoURL];
        avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        avPlayerLayer.frame = self.layer.bounds;
        [self.layer addSublayer: avPlayerLayer];
        [avPlayer play];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
}

-(void) stopAnimating{
    if([self isAnimating]){
        [avPlayerLayer removeFromSuperlayer];
        avPlayerLayer = nil;
        [avPlayer pause];
        avPlayer = nil;
        
        imageView.hidden = NO;
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
