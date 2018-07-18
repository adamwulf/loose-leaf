//
//  MMMirrorLineView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMMirrorLineView.h"


@implementation MMMirrorLineView {
    UIView* _verticalLine;
    UIView* _horizontalLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _verticalLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(frame) - .5, 0, 1, CGRectGetHeight(frame))];
        _horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(frame) - .5, CGRectGetWidth(frame), 1)];

        [_verticalLine setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
        [_horizontalLine setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];

        [_verticalLine setHidden:YES];
        [_horizontalLine setHidden:YES];

        [self addSubview:_verticalLine];
        [self addSubview:_horizontalLine];

        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setMirrorMode:(MirrorMode)mirrorMode {
    _mirrorMode = mirrorMode;

    [_verticalLine setHidden:YES];
    [_horizontalLine setHidden:YES];

    switch ([self mirrorMode]) {
        case MirrorModeVertical:
            [_verticalLine setHidden:NO];
            break;
        case MirrorModeHorizontal:
            [_horizontalLine setHidden:NO];
            break;
        default:
            break;
    }
}

@end
