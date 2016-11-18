//
//  MMConfirmDeleteStackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMConfirmDeleteStackButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"


@implementation MMConfirmDeleteStackButton

- (instancetype)initWithFrame:(CGRect)frame {
    UIColor* iconColor = [UIColor colorWithWhite:.2 alpha:1.0];

    UIImage* trashImg = [MMTrashButton trashIconWithColor:iconColor];
    UIImage* undoImg = [MMUndoRedoButton undoIconWithColor:iconColor];

    if (self = [super initWithFrame:frame andPrompt:@"Are you sure you want to delete these pages?" andLeftIcon:trashImg andLeftTitle:@"Delete" andRightIcon:undoImg andRightTitle:@"Undo"]) {
        // noop
    }
    return self;
}

@end
