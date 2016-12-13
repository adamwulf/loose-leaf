//
//  MMPapersIcon.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMPapersIcon : UIView {
    NSInteger numberToShowIfApplicable;
}

@property (nonatomic, assign) NSInteger numberToShowIfApplicable;

+ (UIImage*)papersIconWithColor:(UIColor*)color;

@end
