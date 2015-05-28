//
//  MMTutorialSidebarButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTextButton.h"

@interface MMTutorialSidebarButton : MMTextButton

-(id) initWithFrame:(CGRect)frame andTutorialList:(NSArray*(^)())_tutorialList;

-(id) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

-(id) initWithFrame:(CGRect)_frame andFont:(UIFont*)_font andLetter:(NSString*)_letter andXOffset:(CGFloat)_xOffset andYOffset:(CGFloat)_yOffset NS_UNAVAILABLE;

-(NSArray*) tutorialList;

@end
