//
//  MMImageViewButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"

@interface MMImageViewButton : MMSidebarButton{
    BOOL darkBg;
}

@property (assign, getter = isDarkBg) BOOL darkBg;

-(void) setImage:(UIImage*)img;

@end
