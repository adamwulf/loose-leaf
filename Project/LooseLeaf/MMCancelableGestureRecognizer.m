//
//  MMCancelableGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCancelableGestureRecognizer.h"

@implementation MMCancelableGestureRecognizer


-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}

@end
