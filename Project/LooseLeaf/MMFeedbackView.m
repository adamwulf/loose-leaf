//
//  MMFeedbackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackView.h"
#import "TestFlight.h"
#import "DYRateView.h"
#import "UIPlaceHolderTextView.h"


@implementation MMFeedbackView{
    UIView* contentView;
    DYRateView* penRatingView;
    DYRateView* eraserRatingView;
    DYRateView* gestureRatingView;
    DYRateView* performanceRatingView;
    UIPlaceHolderTextView* furtherComments;
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
        
        
        // title
        
        UILabel* feedbackTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 30)];
        feedbackTitle.textAlignment = NSTextAlignmentCenter;
        feedbackTitle.text = @"Feedback";
        feedbackTitle.font = [UIFont boldSystemFontOfSize:18];
        feedbackTitle.backgroundColor = [UIColor clearColor];
        [contentView addSubview:feedbackTitle];

        UILabel* feedbackSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, self.frame.size.width-60, 60)];
        feedbackSubTitle.textAlignment = NSTextAlignmentCenter;
        feedbackSubTitle.numberOfLines = 0;
        feedbackSubTitle.text = @"Thanks for your help testing Loose Leaf!";
        feedbackSubTitle.backgroundColor = [UIColor clearColor];
        [contentView addSubview:feedbackSubTitle];
        
        
        
        // ratings
        
        UILabel* penRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 130, 360, 40)];
        penRatingLabel.text = @"The pen is perfect:";
        penRatingLabel.backgroundColor = [UIColor clearColor];
        [penRatingLabel sizeToFit];
        [contentView addSubview:penRatingLabel];
        penRatingView = [[DYRateView alloc] initWithFrame:CGRectMake(300, 130, 160, 40)
                                                 fullStar:[UIImage imageNamed:@"StarFullLarge.png"]
                                                emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
        penRatingView.editable = YES;
        [contentView addSubview:penRatingView];
        

        UILabel* eraserRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 170, 360, 40)];
        eraserRatingLabel.text = @"The eraser is perfect:";
        eraserRatingLabel.backgroundColor = [UIColor clearColor];
        [eraserRatingLabel sizeToFit];
        [contentView addSubview:eraserRatingLabel];
        eraserRatingView = [[DYRateView alloc] initWithFrame:CGRectMake(300, 170, 160, 40)
                                                 fullStar:[UIImage imageNamed:@"StarFullLarge.png"]
                                                emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
        eraserRatingView.editable = YES;
        [contentView addSubview:eraserRatingView];
        

        UILabel* gestureRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 210, 360, 40)];
        gestureRatingLabel.text = @"Gestures are intuitive:";
        gestureRatingLabel.backgroundColor = [UIColor clearColor];
        [gestureRatingLabel sizeToFit];
        [contentView addSubview:gestureRatingLabel];
        gestureRatingView = [[DYRateView alloc] initWithFrame:CGRectMake(300, 210, 160, 40)
                                                    fullStar:[UIImage imageNamed:@"StarFullLarge.png"]
                                                   emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
        gestureRatingView.editable = YES;
        [contentView addSubview:gestureRatingView];
        

        UILabel* performanceRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 250, 360, 40)];
        performanceRatingLabel.text = @"The app is fast:";
        performanceRatingLabel.backgroundColor = [UIColor clearColor];
        [performanceRatingLabel sizeToFit];
        [contentView addSubview:performanceRatingLabel];
        performanceRatingView = [[DYRateView alloc] initWithFrame:CGRectMake(300, 250, 160, 40)
                                                     fullStar:[UIImage imageNamed:@"StarFullLarge.png"]
                                                    emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
        performanceRatingView.editable = YES;
        [contentView addSubview:performanceRatingView];
        
        
        
        furtherComments = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(30, 300, self.frame.size.width-60, 140)];
        furtherComments.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        furtherComments.layer.borderColor = [UIColor blackColor].CGColor;
        furtherComments.layer.borderWidth = 1;
        furtherComments.layer.cornerRadius = 2;
        furtherComments.placeholder = @"Tell me what you love, hate, and in between...";
        [contentView addSubview:furtherComments];
        
        // buttons
        
        UIButton* sendFeedbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sendFeedbackButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
        [sendFeedbackButton addTarget:self action:@selector(submitFeedback) forControlEvents:UIControlEventTouchUpInside];
        [sendFeedbackButton sizeToFit];
        sendFeedbackButton.frame = CGRectMake(280, 510, sendFeedbackButton.frame.size.width, sendFeedbackButton.frame.size.height);
        [contentView addSubview:sendFeedbackButton];
        
        UIButton* cancelFeedbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelFeedbackButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelFeedbackButton addTarget:self action:@selector(cancelFeedback) forControlEvents:UIControlEventTouchUpInside];
        [cancelFeedbackButton sizeToFit];
        cancelFeedbackButton.frame = CGRectMake(40, 510, cancelFeedbackButton.frame.size.width, cancelFeedbackButton.frame.size.height);
        [contentView addSubview:cancelFeedbackButton];
        
        self.alpha = 0;
        
    }
    return self;
}


#pragma mark - button actions

-(void) submitFeedback{
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    NSString* shortVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    NSString* feedback = [NSString stringWithFormat:@"Pen: %f\nEraser:%f\nGesture:%f\nSpeed:%f\n\nComments:\n%@\n\nVersion:%@\nShort Version:%@", penRatingView.rate, eraserRatingView.rate, gestureRatingView.rate, performanceRatingView.rate, furtherComments.text, version, shortVersion];
    [TestFlight submitFeedback:feedback];
    [self hide];
}


-(void) cancelFeedback{
    [self hide];
}


-(void) hide{
    [furtherComments resignFirstResponder];
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
        penRatingView.rate = 0;
        eraserRatingView.rate = 0;
        gestureRatingView.rate = 0;
        performanceRatingView.rate = 0;
        furtherComments.text = @"";
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
