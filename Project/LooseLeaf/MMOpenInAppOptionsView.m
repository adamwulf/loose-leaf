//
//  MMShareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInAppOptionsView.h"
#import "MMOpenInAppManager.h"
#import "MMOpenInAppSidebarButton.h"
#import "UIView+Debug.h"
#import "Constants.h"
#import "UIDevice+PPI.h"
#import "MMRotationManager.h"

@implementation MMOpenInAppOptionsView{
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

-(void) reset{
    [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [buttons removeAllObjects];
    self.alpha = 0;
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
    NSArray* allCollectionViews = [[MMOpenInAppManager sharedInstance] allFoundCollectionViews];
    NSInteger columnCount = floor(self.bounds.size.width / self.buttonWidth);
    NSInteger section = 0;
    NSInteger totalNumberOfItemsInPreviousSections = 0;
    
    for(int section = 0;section<[allCollectionViews count];section++){
        if(section == indexPath.section) break;
        UICollectionView* cv = [allCollectionViews objectAtIndex:section];
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        if([UIDevice majorVersion] >= 8){
            numberOfItems--;
        }
        totalNumberOfItemsInPreviousSections += numberOfItems;
    }
    
    if([allCollectionViews count] > indexPath.section){
        UICollectionView* cv = [allCollectionViews objectAtIndex:indexPath.section];
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        if([UIDevice majorVersion] >= 8){
            numberOfItems--;
        }
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
                CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
                button.rotation = [self sidebarButtonRotation];
                button.transform = rotationTransform;
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
        if([UIDevice majorVersion] >= 8){
            numberOfItems--;
        }

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
    [self show];
    if(!self.alpha){
        [self show];
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

-(void) isSendingToApplication:(NSString *)application{
    // noops
}

#pragma mark - Rotation

-(CGFloat) sidebarButtonRotation{
    if([MMRotationManager sharedInstace].lastBestOrientation == UIInterfaceOrientationPortrait){
        return 0;
    }else if([MMRotationManager sharedInstace].lastBestOrientation == UIInterfaceOrientationLandscapeLeft){
        return -M_PI_2;
    }else if([MMRotationManager sharedInstace].lastBestOrientation == UIInterfaceOrientationLandscapeRight){
        return M_PI_2;
    }else{
        return M_PI;
    }
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation{
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        for(MMBounceButton* button in buttons){
            button.rotation = [self sidebarButtonRotation];
            button.transform = rotationTransform;
        }
    }];
}

#pragma mark - Actions

-(void) buttonTapped:(id)obj{
    [delegate itemWasTappedInShareView];
}

@end
