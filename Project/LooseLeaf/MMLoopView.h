//
//  MMLoopView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMLoopView : UIView

- (instancetype)init NS_UNAVAILABLE;
- (instancetype) initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

-(id) initWithTitle:(NSString*)_title forTutorialId:(NSString*)tutorialId;

+(BOOL) supportsURL:(NSURL*)url;

@property (readonly) NSString* title;
@property (readonly) NSString* tutorialId;
@property (assign) BOOL wantsHiddenButtons;

-(BOOL) wantsNextButton;
-(BOOL) isBuffered;
-(BOOL) isAnimating;
-(void) startAnimating;
-(void) pauseAnimating;
-(void) stopAnimating;

-(void) setDuration:(CGFloat)duration;
-(void) fadeDurationBar;

@end
