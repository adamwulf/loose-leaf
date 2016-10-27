//
//  MMLoopingVideoView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMLoopingVideoView : UIView

+ (BOOL)supportsURL:(NSURL*)url;

- (id)initForVideo:(NSURL*)videoURL withFrame:(CGRect)frame;

- (void)startAnimating;

@end
