//
//  MMImageViewButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDarkSidebarButton.h"

@interface MMImageViewButton : MMDarkSidebarButton{
    BOOL darkBg;
    BOOL greyscale;
    UIImage* image;
}

@property (assign, getter = isDarkBg) BOOL darkBg;
@property (assign, getter = isGreyscale) BOOL greyscale;

-(void) setImage:(UIImage*)img;

@end
