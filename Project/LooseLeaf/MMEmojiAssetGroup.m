//
//  MMEmojiAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiAssetGroup.h"
#import "MMEmojiAsset.h"


@implementation MMEmojiAssetGroup {
    NSArray<MMEmojiAsset*>* _emojis;
}


#pragma mark - Singleton

static MMEmojiAssetGroup* _instance = nil;

+ (MMEmojiAssetGroup*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - MMDisplayAssetGroup

- (instancetype)init {
    if (_instance)
        return _instance;
    if (self = [super init]) {
        _emojis = @[[[MMEmojiAsset alloc] initWithEmoji:@"😀" withName:@"grin"],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😂" withName:@"joy"],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤣" withName:@"rofl"],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😍" withName:@"hearteyes"],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😉" withName:@"wink"]];
    }
    return self;
}

- (NSURL*)assetURL {
    return [NSURL URLWithString:@"loose-leaf://emoji"];
}

- (NSString*)name {
    return @"Emojis";
}

- (NSString*)persistentId {
    return @"LooseLeaf/Emojis";
}

- (NSInteger)numberOfPhotos {
    return [_emojis count];
}

- (NSArray*)previewPhotos {
    return [_emojis subarrayWithRange:NSMakeRange(0, [self numberOfPreviewPhotos])];
}

- (BOOL)reversed {
    return NO;
}

- (short)numberOfPreviewPhotos {
    return 4;
}

- (void)loadPreviewPhotos {
    // noop
}

- (void)unloadPreviewPhotos {
    // noop
}

- (void)loadPhotosAtIndexes:(NSIndexSet*)indexSet usingBlock:(MMDisplayAssetGroupEnumerationResultsBlock)enumerationBlock {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* _Nonnull stop) {
        if (idx < [_emojis count]) {
            MMEmojiAsset* emoji = _emojis[idx];

            enumerationBlock(emoji, idx, stop);
        }
    }];
}

@end
