//
//  MMFeedbackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackView.h"
#import "TestFlight.h"


@implementation MMFeedbackView{
    UIView* contentView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.layer.cornerRadius = 10;
        contentView.clipsToBounds = YES;
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:contentView];
        
        // Initialization code
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:10].CGPath;
        self.layer.shadowRadius = 4;
        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.75].CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.cornerRadius = 10;
        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.backgroundColor = [UIColor whiteColor];
        
        
        UIButton* sendFeedbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sendFeedbackButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
        [sendFeedbackButton addTarget:self action:@selector(submitFeedback) forControlEvents:UIControlEventTouchUpInside];
        [sendFeedbackButton sizeToFit];
        sendFeedbackButton.frame = CGRectMake(280, 540, sendFeedbackButton.frame.size.width, sendFeedbackButton.frame.size.height);
        [contentView addSubview:sendFeedbackButton];
        
        UIButton* cancelFeedbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelFeedbackButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelFeedbackButton addTarget:self action:@selector(cancelFeedback) forControlEvents:UIControlEventTouchUpInside];
        [cancelFeedbackButton sizeToFit];
        cancelFeedbackButton.frame = CGRectMake(40, 540, cancelFeedbackButton.frame.size.width, cancelFeedbackButton.frame.size.height);
        [contentView addSubview:cancelFeedbackButton];
        
        self.alpha = 0;
        
    }
    return self;
}


#pragma mark - button actions

-(void) submitFeedback{
    //    [TestFlight submitFeedback:<#(NSString *)#>];
    [self hide];
}


-(void) cancelFeedback{
    [self hide];
}


-(void) hide{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(.9, .9);
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             [self removeFromSuperview];
                             self.transform = CGAffineTransformIdentity;
                         }
                     }];
}

-(void) show{
    if(self.alpha == 0){
        self.transform = CGAffineTransformMakeScale(.9, .9);
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished){
                                 [UIView animateWithDuration:0.15
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      self.transform = CGAffineTransformIdentity;
                                                  }
                                                  completion:nil];
                             }
                         }];
    }
}

@end
