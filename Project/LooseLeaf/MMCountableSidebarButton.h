//
//  MMCountableSidebarButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUUIDView.h"


@interface MMCountableSidebarButton : UIButton

@property (nonatomic) UIView<MMUUIDView>* view;
@property (nonatomic, assign) NSInteger rowNumber;

+ (CGSize)sizeOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width;

@end
