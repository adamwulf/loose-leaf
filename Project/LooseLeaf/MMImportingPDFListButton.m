//
//  MMImportingPDFButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMImportingPDFListButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"
#import "MMPapersIcon.h"


@implementation MMImportingPDFListButton

- (instancetype)initWithFrame:(CGRect)frame {
    UIColor* iconColor = [UIColor colorWithWhite:.2 alpha:1.0];

    UIImage* trashImg = [MMTrashButton trashIconWithColor:iconColor];

    if (self = [super initWithFrame:frame andPrompt:@"Importing PDF Page 0 / 0" andLeftIcon:trashImg andLeftTitle:@"Cancel" andRightIcon:nil andRightTitle:nil]) {
        // noop
    }
    return self;
}

@end
