//
//  MMVideoLoopView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMVideoLoopView : UIView

- (instancetype)init NS_UNAVAILABLE;
- (instancetype) initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

-(id) initForVideo:(NSURL*)videoURL;


-(BOOL) isAnimating;
-(void) startAnimating;
-(void) stopAnimating;

@end
