//
//  MMCloudKitOptionsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOptionsView.h"

@implementation MMCloudKitOptionsView

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel* cloudKitLabel = [[UILabel alloc] initWithFrame:self.bounds];
        cloudKitLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        cloudKitLabel.text = @"cloudkit!";
    }
    return self;
}

@end
