//
//  MMStackButtonView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackButtonView.h"
#import "MMSingleStackManager.h"
#import "MMAllStacksManager.h"
#import "MMTextButton.h"
#import "MMStackIconView.h"
#import "NSArray+Extras.h"
#import <JotUI/UIImage+Alpha.h>

@implementation MMStackButtonView{
    NSString* stackUUID;
    MMStackIconView* icon;
    UIButton* stackButton;
    UIButton* nameButton;
}

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)_stackUUID{
    if(self = [super initWithFrame:frame]){

        [self clipsToBounds];
        
        stackUUID = _stackUUID;
        
        CGFloat stackIconHeight = 220;
        
        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        CGFloat scale = stackIconHeight / CGRectGetHeight(screenBounds);
        CGRect thumbFrame = CGRectApplyAffineTransform(screenBounds, CGAffineTransformMakeScale(scale, scale));
        thumbFrame.origin.x += (CGRectGetWidth(self.bounds) - CGRectGetWidth(thumbFrame)) / 2;
        thumbFrame.origin.y = 30;
        
        icon = [[MMStackIconView alloc] initWithFrame:thumbFrame andStackUUID:stackUUID andStyle:MMStackIconViewStyleDark];
        
        stackButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [stackButton addTarget:self action:@selector(switchToStackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stackButton];

        CGRect buttonFrame = CGRectMake(15, CGRectGetMaxY(thumbFrame), CGRectGetWidth(self.bounds) - 30, CGRectGetHeight(self.bounds) - CGRectGetMaxY(thumbFrame) - 15);
        nameButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [self addSubview:nameButton];
        [nameButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [nameButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [nameButton.titleLabel setMinimumScaleFactor:.9];
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        nameButton.titleLabel.numberOfLines = 2;
        nameButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [nameButton addTarget:self action:@selector(didTapNameForStack:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:icon];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"StackCachedPagesDidUpdateNotification" object:nil];
    }
    return self;
}

-(void) refresh{
    NSString* stackName = [[MMAllStacksManager sharedInstance] nameOfStack:stackUUID];
    if([stackName length]){
        [nameButton setTitle:stackName forState:UIControlStateNormal];
        [nameButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        [nameButton setTitle:@"No Name" forState:UIControlStateNormal];
        [nameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    
    [icon loadThumbs];
}

-(void) switchToStackAction:(id)sender{
    [[self delegate] switchToStackAction:stackUUID];
}

-(void) didTapNameForStack:(id)sender{
    [[self delegate] didTapNameForStack:stackUUID];
}


@end
