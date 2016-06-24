//
//  MMAbstractShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMAbstractShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMAbstractShareItem

@synthesize delegate;

-(MMSidebarButton*) button{
    @throw kAbstractMethodException;
}

-(BOOL) isAtAllPossible{
    @throw kAbstractMethodException;
}

-(void) willShow{
    // noop
}

-(void) didHide{
    // noop
}


-(void) animateCompletionText:(NSString*)linkText withImage:(UIImage*)icon{
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    imgView.image = icon;
    
    UILabel* labelForLink = [[UILabel alloc] initWithFrame:CGRectZero];
    labelForLink.alpha = 0;
    labelForLink.text = [NSString stringWithFormat:@"       %@", linkText];
    labelForLink.font = [UIFont boldSystemFontOfSize:16];
    labelForLink.textAlignment = NSTextAlignmentCenter;
    labelForLink.textColor = [UIColor whiteColor];
    labelForLink.clipsToBounds = YES;
    labelForLink.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
    labelForLink.layer.borderColor = [UIColor whiteColor].CGColor;
    labelForLink.layer.borderWidth = 1.0;
    labelForLink.layer.cornerRadius = 20;
    [labelForLink sizeToFit];
    CGRect winFr = self.button.window.bounds;
    CGRect fr = labelForLink.frame;
    fr.size.height = 40;
    fr.size.width += 40;
    fr.origin.x = (winFr.size.width - fr.size.width) / 2;
    fr.origin.y = 40;
    labelForLink.frame = fr;
    [labelForLink addSubview:imgView];
    [self.button.window addSubview:labelForLink];
    
    [UIView animateWithDuration:.3 animations:^{
        labelForLink.alpha = 1;
    }completion:^(BOOL finished){
        [[NSThread mainThread] performBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                labelForLink.alpha = 0;
            }completion:^(BOOL finished){
                [labelForLink removeFromSuperview];
            }];
        } afterDelay:2.2];
    }];
}

@end
