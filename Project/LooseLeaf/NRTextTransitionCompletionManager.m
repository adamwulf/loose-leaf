//
//  NRTextTransitionCompletionManager.m
//  NRTextTransitionsExample
//
//  Created by Natan Rolnik on 2/26/14.
//
//

#import "NRTextTransitionCompletionManager.h"


@interface NRTextTransitionCompletionManager () {
    NSMutableDictionary* completionsDictionary;
}
@end


@implementation NRTextTransitionCompletionManager

+ (instancetype)sharedManager {
    static NRTextTransitionCompletionManager* _sharedNRTextTransitionCompletionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNRTextTransitionCompletionManager = [[NRTextTransitionCompletionManager alloc] init];
    });

    return _sharedNRTextTransitionCompletionManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        completionsDictionary = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag {
    NSString* theKey = [anim valueForKey:@"id"];

    if (theKey) {
        void (^completionBlock)(void) = [completionsDictionary objectForKey:theKey];

        if (completionBlock) {
            completionBlock();
            [completionsDictionary removeObjectForKey:theKey];
        }
    }
}

- (void)setCompletionBlock:(void (^)(void))completion forKey:(NSString*)key {
    if (completion && key) {
        [completionsDictionary setObject:completion forKey:key];
    }
}

@end
