//
//  MMBufferedImageView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MMBufferedImage : NSObject

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIImage* image;

- (id)initWithFrame:(CGRect)frame;

-(void) drawRect:(CGRect)rect;

@end
