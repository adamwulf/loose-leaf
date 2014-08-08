//
//  MMEmailShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEmailShareItem.h"
#import "MMImageViewButton.h"
#import "Constants.h"

@implementation MMEmailShareItem{
    MMImageViewButton* button;
}

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"email"]];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

@end
