//
//  SLPaperView+ListView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperView+ListView.h"



@implementation SLPaperView (ListView)

-(NSInteger) rowInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate rowInListViewGivenIndex:indexOfPage];
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate columnInListViewGivenIndex:indexOfPage];
}

@end
