//
//  MMCloudKitExportAnimationView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportView.h"
#import "MMUntouchableView.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMCloudKitExportView{
    NSMutableSet* disappearingButtons;
}

@synthesize animationHelperView;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        disappearingButtons = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [animationHelperView addSubview:avatarButton];
    
    avatarButton.shouldDrawDarkBackground = YES;
    [avatarButton setNeedsDisplay];
    
    [avatarButton animateBounceToTopOfScreenAtX:100 withDuration:0.8 completion:^(BOOL finished) {
        [self addSubview:avatarButton];
        [avatarButton animateToPercent:1.0 success:YES completion:^(BOOL finished) {
            if(finished){
                //                    [delegate didShare:self];
            }
            [[NSThread mainThread] performBlock:^{
                [disappearingButtons addObject:avatarButton];
                [avatarButton animateOffScreenWithCompletion:^(BOOL finished) {
                    [disappearingButtons removeObject:avatarButton];
                }];
                [self animateAndAlignAllButtons];
            } afterDelay:10.0 + rand()%10];
        }];
        [self animateAndAlignAllButtons];
    }];
    [self animateAndAlignAllButtons];
}


-(void) animateAndAlignAllButtons{
    [UIView animateWithDuration:.5 animations:^{
        int i=0;
        for(MMAvatarButton* button in [self.subviews reverseObjectEnumerator]){
            if([button isKindOfClass:[MMAvatarButton class]] &&
               ![disappearingButtons containsObject:button]){
                
                CGRect fr = button.frame;
                fr.origin.x = 100 + button.frame.size.width/2*(i+[animationHelperView.subviews count]);
                button.frame = fr;
                i++;
            }
        }
    }];
}

@end
