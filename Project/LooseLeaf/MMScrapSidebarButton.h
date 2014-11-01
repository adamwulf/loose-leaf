//
//  MMScrapMenuButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapView.h"

@interface MMScrapSidebarButton : UIButton

@property (nonatomic) MMScrapView* scrap;
@property (nonatomic, assign) NSInteger rowNumber;

+(CGSize) sizeOfRowForScrap:(MMScrapView*)scrap forWidth:(CGFloat)width;

@end
