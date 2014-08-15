//
//  MMShareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareView.h"
#import "MMShareManager.h"
#import "MMOpenInAppSidebarButton.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMShareView{
    NSMutableArray* buttons;
    UIView* line;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        buttons = [NSMutableArray array];
        
        CGFloat width = frame.size.width;
        CGRect lineRect = CGRectMake(width*0.1, 0, width*0.8, 1);
        line = [[UIView alloc] initWithFrame:lineRect];
        line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        [self addSubview:line];
    }
    return self;
}

-(void) reset{
    [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [buttons removeAllObjects];
    self.alpha = 0;
}

-(void) hide{
    CGRect origFrame = self.frame;
    CGRect offsetFrame = origFrame;
    offsetFrame.origin.y += 10;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0;
        self.frame = offsetFrame;
    }completion:^(BOOL finished){
        if(finished){
            self.frame = origFrame;
        }
    }];
}

#pragma mark - MMShareManagerDelegate

// something changed with our buttons,
// so expect to reload them
-(void) allCellsWillLoad{
    // don't do anything yet
}

// we've just been notified that a cell is ready.
// build and show the button
-(void) cellLoaded:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath{
    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
    NSInteger columnCount = floor(self.bounds.size.width / self.buttonWidth);
    NSInteger section = 0;
    NSInteger totalNumberOfItemsInPreviousSections = 0;
    
    for(int section = 0;section<[allCollectionViews count];section++){
        if(section == indexPath.section) break;
        UICollectionView* cv = [allCollectionViews objectAtIndex:section];
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        totalNumberOfItemsInPreviousSections += numberOfItems;
    }
    
    if([allCollectionViews count] > indexPath.section){
        UICollectionView* cv = [allCollectionViews objectAtIndex:indexPath.section];
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        if(indexPath.row < numberOfItems){
            NSInteger currentIndex = totalNumberOfItemsInPreviousSections + indexPath.row;
            NSInteger row = floor(currentIndex / columnCount);
            NSInteger col = currentIndex % columnCount;
            
            CGRect buttonFr = CGRectMake(col * self.buttonWidth, kWidthOfSidebarButtonBuffer + row * self.buttonWidth,
                                         self.buttonWidth, self.buttonWidth);
            MMOpenInAppSidebarButton* button = nil;
            if([buttons count] > currentIndex) button = [buttons objectAtIndex:currentIndex];
            if(!button){
                button = [[MMOpenInAppSidebarButton alloc] initWithFrame:buttonFr andIndexPath:indexPath];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [buttons addObject:button];
                [self addSubview:button];
            }else{
                button.frame = buttonFr;
                button.indexPath = indexPath;
            }
        }
    }
    
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        
        for(int index=0;index<numberOfItems;index++){
            NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
            [cv cellForItemAtIndexPath:path];
        }
        totalNumberOfItemsInPreviousSections += numberOfItems;
        section++;
    }
    
    CGRect fr = self.frame;
    fr.size.height = totalNumberOfItemsInPreviousSections * (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer) + kWidthOfSidebarButtonBuffer;
    self.frame = fr;
}

// ok, everything is done. animate the view
// into place if needbe
-(void) allCellsLoaded:(NSArray *)arrayOfAllLoadedButtonIndexes{
    if(!self.alpha){
        NSLog(@"done loading all buttons: %d vs %d", [buttons count], [arrayOfAllLoadedButtonIndexes count]);
        CGRect origFrame = self.frame;
        CGRect offsetFrame = origFrame;
        offsetFrame.origin.y += 10;
        self.frame = offsetFrame;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1;
            self.frame = origFrame;
        }completion:nil];
    }else{
        for (NSUInteger index = [arrayOfAllLoadedButtonIndexes count]; index < [buttons count]; index++) {
            [[buttons objectAtIndex:index] removeFromSuperview];
            [buttons removeObjectAtIndex:index];
        }
    }
}

-(void) sharingHasEnded{
    if(self.alpha){
        [self hide];
    }
}

#pragma mark - Actions

-(void) buttonTapped:(id)obj{
    [delegate didShare];
}

@end
