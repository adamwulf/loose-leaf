//
//  MMShareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareView.h"
#import "MMShareManager.h"

@implementation MMShareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGFloat loc = 0;
    
    NSArray* allCollectionViews = [[MMShareManager sharedInstace] allViews];
    
    
    NSLog(@"checking on %d views", [allCollectionViews count]);
    for(UICollectionView* cv in allCollectionViews){
        
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        
        NSLog(@"checking on %d items", numberOfItems);
        
        for(NSInteger i=0;i<numberOfItems;i++){
            UICollectionViewCell* cell = [cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            CGPoint origin = CGPointMake(300+loc, loc);
            CGSize size = cell.bounds.size;
            CGRect fr;
            fr.origin = origin;
            fr.size = size;
            
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor redColor].CGColor);
            CGContextStrokeRect(UIGraphicsGetCurrentContext(), fr);
            
            [cell drawViewHierarchyInRect:fr afterScreenUpdates:NO];
            
            loc += 10;
        }
    }
    
}

@end
