//
//  MMVideoLoopView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMVideoLoopView.h"
#import <AVFoundation/AVFoundation.h>

@implementation MMVideoLoopView{
    AVPlayer* avPlayer;
    AVPlayerLayer* avPlayerLayer;
}

-(id) initForVideo:(NSURL*)videoURL{
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]){
        avPlayer = [AVPlayer playerWithURL:videoURL];
        avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        
        avPlayerLayer.frame = self.layer.bounds;
        [self.layer addSublayer: avPlayerLayer];
        [avPlayer play];
        
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
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
        [avPlayer play];
    }
}

-(void) stopAnimating{
    if([self isAnimating]){
        [avPlayer pause];
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
