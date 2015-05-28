//
//  MMLoopView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMLoopView.h"
#import "Constants.h"
#import "UIColor+Shadow.h"
#import "MMTutorialManager.h"

@implementation MMLoopView{
    
    UILabel* titleLabel;
    UIView* durationBar;

}

@synthesize title;
@synthesize tutorialId;

+(BOOL) supportsURL:(NSURL*)url{
    return NO;
}

-(id) initWithTitle:(NSString*)_title forTutorialId:(NSString*)_tutorialId{
    if(self = [super initWithFrame:CGRectMake(0, 0, 600, 600)]){
        title = _title;
        tutorialId = _tutorialId;
        
        if(title){
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = _title;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:titleLabel];
        }
        
        durationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
        durationBar.clipsToBounds = YES;
        durationBar.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [self addSubview:durationBar];

        if(title){
            UILabel* durationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
            durationTitleLabel.backgroundColor = [UIColor clearColor];
            durationTitleLabel.textColor = [UIColor whiteColor];
            durationTitleLabel.text = _title;
            durationTitleLabel.textAlignment = NSTextAlignmentCenter;
            [durationBar addSubview:durationTitleLabel];
        }
    }
    return self;
}

-(void) setDuration:(CGFloat)duration{
    if(!tutorialId) return;
    CGFloat maxWidth = self.bounds.size.width;
    CGRect fr = durationBar.frame;
    fr.size.width = maxWidth * duration;
    if(![[MMTutorialManager sharedInstance] hasCompletedStep:tutorialId]){
        durationBar.frame = fr;
    }
}

-(void) fadeDurationBar{
    [UIView animateWithDuration:.3 animations:^{
        durationBar.alpha = 0;
    }];
}

-(BOOL) wantsNextButton{
    @throw kAbstractMethodException;
}

-(BOOL) isBuffered{
    @throw kAbstractMethodException;
}

-(BOOL) isAnimating{
    @throw kAbstractMethodException;
}

-(void) startAnimating{
    @throw kAbstractMethodException;
}

-(void) pauseAnimating{
    @throw kAbstractMethodException;
}

-(void) stopAnimating{
    @throw kAbstractMethodException;
}

@end
