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
    }
    return self;
}

#pragma mark - MMShareManagerDelegate

-(void) cellLoaded:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath{
    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
    NSInteger columnCount = floor(self.bounds.size.width / self.buttonWidth);
    NSInteger section = 0;
    NSInteger totalNumberOfItemsInPreviousSections = 0;
    
    for(int section = 0;section<[allCollectionViews count];section++){
        if(section == indexPath.section) break;
        UICollectionView* cv = [allCollectionViews objectAtIndex:indexPath.section];
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
            
            CGRect buttonFr = CGRectMake(col * self.buttonWidth, row * self.buttonWidth,
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
            NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:section];
            [cv cellForItemAtIndexPath:path];
            

        }
        totalNumberOfItemsInPreviousSections += numberOfItems;
        section++;
    }
    
    CGRect fr = self.frame;
    fr.size.height = totalNumberOfItemsInPreviousSections * (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer);
    self.frame = fr;
    [self setNeedsDisplay];

}

-(void) buttonTapped:(id)obj{
    NSLog(@"shareButtonTapped");
    [delegate didShare];
}

@end
