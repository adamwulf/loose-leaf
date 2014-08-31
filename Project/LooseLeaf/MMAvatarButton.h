//
//  MMAvatarButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"

@interface MMAvatarButton : MMSidebarButton

@property (nonatomic, assign) BOOL shouldDrawDarkBackground;
@property (nonatomic, assign) BOOL targetSuccess;
@property (nonatomic, assign) CGFloat targetProgress;

- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)letter;

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded completion:(void (^)(BOOL finished))completion;

-(void) animateBounceToTopOfScreenAtX:(CGFloat)xLoc withDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

-(void) animateOnScreenWithCompletion:(void (^)(BOOL finished))completion;

-(void) animateOffScreenWithCompletion:(void (^)(BOOL finished))completion;

@end
