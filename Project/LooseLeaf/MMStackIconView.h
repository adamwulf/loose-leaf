//
//  MMStackIconView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum NSInteger {
    MMStackIconViewStyleDark = 0,
    MMStackIconViewStyleLight
} MMStackIconViewStyle;


@interface MMStackIconView : UIView

- (instancetype)initWithFrame:(CGRect)frame andStackUUID:(NSString*)stackUUID andStyle:(MMStackIconViewStyle)style;

- (void)loadThumbs;

@end
