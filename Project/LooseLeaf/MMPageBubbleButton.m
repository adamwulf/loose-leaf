//
//  MMPageBubbleButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPageBubbleButton.h"


@implementation MMPageBubbleButton

@synthesize view;
@synthesize originalViewScale;
@synthesize scale;

+ (CGFloat)idealScaleForView:(MMEditablePaperView*)page {
    return .5;
}

+ (CGAffineTransform)idealTransformForView:(MMEditablePaperView*)page {
    // aim to get the border into 36 px
    CGFloat scale = [MMPageBubbleButton idealScaleForView:page];
    return CGAffineTransformMakeScale(scale, scale);
}

+ (CGRect)idealBoundsForView:(UIView<MMUUIDView>*)view {
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    CGSize listPageSize = CGSizeScale(screenSize, kListPageZoom);
    return CGRectFromSize(listPageSize);
}

- (void)setView:(MMEditablePaperView*)_view {
    view = _view;
    if (!_view) {
        //        DebugLog(@"killing scrap bubble, setting to nil scrap");
        return;
    }

    [self addSubview:view];
    view.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    view.transform = [[self class] idealTransformForView:view];

    view.center = CGRectGetMidPoint([self bounds]);
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTappedDown object:[[event allTouches] anyObject]];
    [super touchesBegan:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event allTouches] anyObject]];
    });
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event allTouches] anyObject]];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemTapped object:[[event allTouches] anyObject]];
    [super touchesCancelled:touches withEvent:event];
}

@end
