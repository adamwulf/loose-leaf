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

- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)letter;

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded;

-(void) animateBounceToTopOfScreenWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

@end
