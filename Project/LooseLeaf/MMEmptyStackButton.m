//
//  MMEmptyStackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/17/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMEmptyStackButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"


@implementation MMEmptyStackButton

- (instancetype)initWithFrame:(CGRect)frame {
    UIColor* iconColor = [UIColor colorWithWhite:.2 alpha:1.0];

    UIImage* trashImg = [MMTrashButton trashIconWithColor:iconColor];
    UIImage* undoImg = [MMUndoRedoButton undoIconWithColor:iconColor];

    if (self = [super initWithFrame:frame andPrompt:@"There are no pages." andLeftIcon:trashImg andLeftTitle:@"Delete" andRightIcon:undoImg andRightTitle:@"Add Pages"]) {
        // noop
    }
    return self;
}
@end
