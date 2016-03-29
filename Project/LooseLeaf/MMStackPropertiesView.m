//
//  MMStackPropertiesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackPropertiesView.h"

@implementation MMStackPropertiesView

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)stackUUID{
    if(self = [super initWithFrame:frame]){

        UILabel* lbl = [[UILabel alloc] initWithFrame:self.bounds];
        lbl.text = stackUUID;
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:lbl];
        
        
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.boxSize, self.boxSize)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.maskedScrollContainer addSubview:contentView];

    }
    return self;
}

@end
