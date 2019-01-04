//
//  MMButtonBoxView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/24/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface MMButtonBoxView : UIView

@property (nonatomic, strong) NSArray<UIButton*>* buttons;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, assign) CGFloat buttonMargin;

@end

NS_ASSUME_NONNULL_END
