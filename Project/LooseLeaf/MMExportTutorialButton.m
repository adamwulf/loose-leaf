//
//  MMExportHelpButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/16/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMExportTutorialButton.h"
#import "UIView+Animations.h"

@implementation MMExportTutorialButton

-(void) bounceButton:(id)sender{
    if(self.enabled){
        self.center = self.center;
        [self bounceWithTransform:[self rotationTransform] stepOne:.2 stepTwo:-.1];
    }
}


@end
