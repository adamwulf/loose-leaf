//
//  MMDebugStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMDebugStackView.h"
#import "MMPageCacheManager.h"
#import "MMPaperStackView.h"
#import "MMLooseLeafViewController.h"


@implementation MMDebugStackView {
    NSTimer* timer;
    UITextView* textView;
}

static MMDebugStackView* _instance = nil;

+ (MMDebugStackView*)sharedView {
    if (!_instance) {
        _instance = [[MMDebugStackView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
    }
    return _instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        textView = [[UITextView alloc] initWithFrame:[self bounds]];
        textView.textContainerInset = UIEdgeInsetsMake(100, 80, 80, 80);
        self.backgroundColor = [UIColor clearColor];
        textView.backgroundColor = [UIColor clearColor];
        [self addSubview:textView];
    }
    return self;
}

- (void)update {
    MMEditablePaperView* page = [[MMPageCacheManager sharedInstance] currentEditablePage];
    MMPaperStackView* stack = (MMPaperStackView*)page.delegate;

    NSString* str = [NSString stringWithFormat:@"%@:%@", stack.uuid, page.uuid];
    str = [str stringByAppendingString:@"\n"];
    str = [str stringByAppendingFormat:@"Visible: %.2f %.2f\n", stack.visibleStackHolder.frame.origin.x, stack.visibleStackHolder.frame.origin.y];

    for (MMPaperView* page in stack.visibleStackHolder.subviews) {
        str = [str stringByAppendingFormat:@" - %@\n", page.uuid];
    }

    str = [str stringByAppendingFormat:@"Bezel: %.2f %.2f\n", stack.bezelStackHolder.frame.origin.x, stack.bezelStackHolder.frame.origin.y];

    for (MMPaperView* page in stack.bezelStackHolder.subviews) {
        str = [str stringByAppendingFormat:@" - %@\n", page.uuid];
    }

    str = [str stringByAppendingFormat:@"Hidden: %.2f %.2f\n", stack.hiddenStackHolder.frame.origin.x, stack.hiddenStackHolder.frame.origin.y];

    for (MMPaperView* page in [stack.hiddenStackHolder.subviews reverseObjectEnumerator]) {
        str = [str stringByAppendingFormat:@" - %@\n", page.uuid];
    }

    textView.text = str;
}


@end
