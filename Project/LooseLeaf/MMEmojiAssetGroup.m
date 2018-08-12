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
        _emojis = @[
            [[MMEmojiAsset alloc] initWithEmoji:@"😀" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"grin" andSize:CGSizeMake(500, 500)],
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
            [[MMEmojiAsset alloc] initWithEmoji:@"😢" andPath:[UIBezierPath emojiCryPathForSize:CGSizeMake(500, 500)] andName:@"cry" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😭" andPath:[UIBezierPath emojiCryPathForSize:CGSizeMake(500, 500)] andName:@"sobbing" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😩" andPath:[UIBezierPath emojiCryPathForSize:CGSizeMake(500, 500)] andName:@"weary" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😠" andPath:[UIBezierPath emojiFacePathForSize:CGSizeMake(500, 500)] andName:@"angry" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤧" andPath:[UIBezierPath emojiSneezePathForSize:CGSizeMake(500, 500)] andName:@"sneeze" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤪" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"zany" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😸" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"smilingcat" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😹" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"joycat" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😻" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"lovecat" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😿" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"crycat" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👶" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"baby" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👦" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"boy" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👧" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"girl" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👨" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"man" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👩" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"woman" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👴" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"oldman" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👵" andPath:[UIBezierPath emojiZanyPathForSize:CGSizeMake(500, 500)] andName:@"oldwoman" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🙏" andPath:[UIBezierPath emojiPrayPathForSize:CGSizeMake(500, 500)] andName:@"pray" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🖖" andPath:[UIBezierPath emojiSpockPathForSize:CGSizeMake(500, 500)] andName:@"spock" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤟" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"iloveyou" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🙌" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"raisinghands" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👏" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"clappinghands" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👋" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"wavinghand" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👊" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"oncomingfist" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👌" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"ok" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤞" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"crossedfingers" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"✌️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"peace" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👍" andPath:[UIBezierPath emojiThumbsUpPathForSize:CGSizeMake(500, 500)] andName:@"thumbsup" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👉" andPath:[UIBezierPath emojiPointerPathForSize:CGSizeMake(500, 500)] andName:@"pointer" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤠" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"cowboy" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"😳" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"flushedface" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💁‍♀️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"womantippinghand" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🤷" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"personshrugging" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💁‍♂️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"mantippinghand" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💩" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"poo" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💥" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"bang" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💨" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"toot" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌕" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"fullmoon" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌙" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"crescentmoon" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌛" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"quartermoonface" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"☀️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"sun" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"☁️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"cloud" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"⛅" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"partlycloudy" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌦️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"suncloudrain" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌧️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"raincloud" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌨️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"snowcloud" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌩️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"thunderstorm" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🔥" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"fire" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🎉" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"partypopper" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🎀" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"pinkbow" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"☠️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"crossbones" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💌" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"loveletter" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"✉️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"envelope" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💋" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"kissmark" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"📍" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"mappin" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"❤️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"redheart" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💔" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"brokenheart" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"👀" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"eyes" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💬" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"speechbubble" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🗯️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"angerbubble" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💭" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"thoughtbubble" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"♠️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"spadesuit" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"♥️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"heartsuit" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"♦️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"diamondsuit" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"♣️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"clubsuit" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🚫" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"prohibited" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"⚠️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"warning" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"☢️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"radioactive" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"♻️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"recycle" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💯" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"100" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💡" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"lightbulb" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"💰" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"moneybag" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🏳️" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"whiteflag" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🏁" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"chequeredflag" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🚩" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"triangleflag" andSize:CGSizeMake(500, 500)],
            [[MMEmojiAsset alloc] initWithEmoji:@"🌟" andPath:[UIBezierPath emojiILoveYouPathForSize:CGSizeMake(500, 500)] andName:@"glowingstar" andSize:CGSizeMake(500, 500)],
        ];
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
