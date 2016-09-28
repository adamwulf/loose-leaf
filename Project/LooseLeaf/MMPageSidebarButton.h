//
//  MMPageSidebarButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMEditablePaperView;


@interface MMPageSidebarButton : UIButton

@property (nonatomic) MMEditablePaperView* page;
@property (nonatomic, assign) NSInteger rowNumber;

+ (CGSize)sizeOfRowForPage:(MMEditablePaperView*)page forWidth:(CGFloat)width;

@end
