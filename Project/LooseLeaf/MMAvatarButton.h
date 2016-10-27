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
@property (nonatomic) NSString* letter;
@property (nonatomic, readonly) UIColor* fontColor;

- (id)initWithFrame:(CGRect)frame forLetter:(NSString*)letter andOffset:(CGPoint)offset;

- (id)initWithFrame:(CGRect)frame forLetter:(NSString*)letter;

- (void)animateToPercent:(CGFloat)progress success:(BOOL)succeeded completion:(void (^)(BOOL finished))completion;

- (void)animateBounceToTopOfScreenAtX:(CGFloat)xLoc
                         withDuration:(CGFloat)duration
                   withTargetRotation:(CGFloat)targetRotation
                           completion:(void (^)(BOOL finished))completion;

- (void)animateOnScreenFrom:(CGPoint)offscreen withCompletion:(void (^)(BOOL finished))completion;

- (void)animateOffScreenWithCompletion:(void (^)(BOOL finished))completion;

@end
