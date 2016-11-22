//
//  MMRoundedButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMRoundedButton.h"


@implementation MMRoundedButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // generate default colors
        UIButton* defButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self setTitleColor:[defButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [self setTitleColor:[defButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [self setTitleColor:[defButton titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
        [self setTitleColor:[defButton titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];

        // setup border
        self.layer.cornerRadius = 10;
        self.layer.borderColor = [self titleColorForState:UIControlStateNormal].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)setTitle:(NSString*)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self sizeToFit];
    CGRect b = self.bounds;
    b.size.width += [self imageForState:UIControlStateNormal] ? 30 : 40;
    b.size.height += 12;
    self.bounds = b;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self setBackgroundColor:[self titleColorForState:UIControlStateNormal]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setTitleColor:(UIColor*)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    self.layer.borderColor = [self titleColorForState:UIControlStateNormal].CGColor;
}

@end
