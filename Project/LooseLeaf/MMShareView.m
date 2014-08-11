//
//  MMShareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareView.h"
#import "MMShareManager.h"
#import "UIView+Debug.h"

@implementation MMShareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
//        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        [self showDebugBorder];
        self.userInteractionEnabled = YES;
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
            
            CGPoint origin = CGPointMake(loc, loc);
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

#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSArray* allCollectionViews = [[MMShareManager sharedInstace] allViews];
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        for(NSInteger i=0;i<numberOfItems;i++){
            UICollectionViewCell* cell = [cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            return cell;
        }
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    NSArray* allCollectionViews = [[MMShareManager sharedInstace] allViews];
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        if(numberOfItems > 1){
            return YES;
        }
    }
    return NO;
}

-(CGPoint) convertPoint:(CGPoint)point toView:(UIView *)view{
    return [super convertPoint:point toView:view];
}

-(CGPoint) convertPoint:(CGPoint)point fromView:(UIView *)view{
    NSArray* allCollectionViews = [[MMShareManager sharedInstace] allViews];
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        for(NSInteger i=0;i<numberOfItems;i++){
            UICollectionViewCell* cell = [cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            CGPoint p = [cell convertPoint:cell.center toView:self];
            return p;
        }
    }
    return [super convertPoint:point fromView:view];
}

@end
