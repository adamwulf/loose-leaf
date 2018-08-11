//
//  MMEmojiAssetGroup.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiAssetGroup.h"
#import "MMEmojiAsset.h"
#import "UIBezierPath+MMEmoji.h"


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
        _emojis = @[[[MMEmojiAsset alloc] initWithEmoji:@"😀" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"grin" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😂" andPath:[UIBezierPath emojiJoyPathForSize:CGSizeMake(500, 500)] andName:@"joy" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤣" andPath:[UIBezierPath emojiRoflPathForSize:CGSizeMake(500, 500)] andName:@"rofl" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😍" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"hearteyes" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😉" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"wink" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"☺️" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"relaxed" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🙄" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"rollingeyes" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😒" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"unamused" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😬" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"grimmace" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤓" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"nerd" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😘" andPath:[UIBezierPath emojiBlowingKissPathForSize:CGSizeMake(500, 500)] andName:@"blowingkiss" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤩" andPath:[UIBezierPath emojiStarStruckPathForSize:CGSizeMake(500, 500)] andName:@"starstruck" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤔" andPath:[UIBezierPath emojiThinkingPathForSize:CGSizeMake(500, 500)] andName:@"thinking" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤐" andPath:[UIBezierPath emojiZipperPathForSize:CGSizeMake(500, 500)] andName:@"zipper" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😴" andPath:[UIBezierPath emojiSleepingPathForSize:CGSizeMake(500, 500)] andName:@"sleeping" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😅" andPath:[UIBezierPath emojiGrinSweatPathForSize:CGSizeMake(500, 500)] andName:@"grinsweat" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😝" andPath:[UIBezierPath emojiSquintToungePathForSize:CGSizeMake(500, 500)] andName:@"squinttounge" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😕" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"confused" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😢" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"cry" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"😠" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"angry" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤧" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"sneeze" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤪" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"zany" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🖖" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"spock" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🙏" andPath:[UIBezierPath emojiPrayPathForSize:CGSizeMake(500, 500)] andName:@"pray" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"🤟" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"iloveyou" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"👍" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"thumbsup" andSize:CGSizeMake(500, 500)],
                    [[MMEmojiAsset alloc] initWithEmoji:@"👉" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"pointer" andSize:CGSizeMake(500, 500)]];
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
