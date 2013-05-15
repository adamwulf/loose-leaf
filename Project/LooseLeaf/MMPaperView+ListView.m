//
//  MMPaperView+ListView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView+ListView.h"



@implementation MMPaperView (ListView)

-(NSInteger) rowInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate rowInListViewGivenIndex:indexOfPage];
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate columnInListViewGivenIndex:indexOfPage];
}

@end
