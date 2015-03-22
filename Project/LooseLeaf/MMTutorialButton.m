//
//  MMTutorialButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialButton.h"

@implementation MMTutorialButton

-(id) initWithFrame:(CGRect)_frame forStepNumber:(NSInteger)stepNumber{
    if(self = [super initWithFrame:_frame andFont:[UIFont systemFontOfSize:12] andLetter:[NSString stringWithFormat:@"%d", (int)stepNumber]
                        andXOffset:0 andYOffset:0]){
        self.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 0.45];
}

@end
