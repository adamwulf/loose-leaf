//
//  MMEmojiAsset.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiAsset.h"
#import "Constants.h"


@implementation MMEmojiAsset {
    NSString* _emoji;
    UIBezierPath* _path;
    NSString* _emojiName;
}

- (instancetype)initWithEmoji:(NSString*)emoji withName:(NSString*)emojiName {
    if (self = [super init]) {
        _emoji = emoji;
        _emojiName = emojiName;
        _path = [UIBezierPath bezierPathWithOvalInRect:CGRectFromSize([self fullResolutionSize])];
    }

    return self;
}

- (UIImage*)aspectRatioThumbnail {
    return nil;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim {
    return nil;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim andRatio:(CGFloat)ratio {
    return nil;
}

- (NSURL*)fullResolutionURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"loose-leaf://shapes/%@.shape", _emojiName]];
}

- (CGSize)fullResolutionSize {
    return CGSizeMake(500, 500);
}

- (CGFloat)defaultRotation {
    return 0;
}

- (CGFloat)preferredImportMaxDim {
    return 500;
}

- (UIBezierPath*)fullResolutionPath {
    return [_path copy];
}

@end
