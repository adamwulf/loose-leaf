//
//  MMPDFInboxContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFInboxContentView.h"
#import "MMDisplayAssetGroupCell.h"
#import "MMContinuousSwipeGestureRecognizer.h"
#import "MMPhotoManager.h"
#import "MMInboxManager.h"
#import "MMPDFAlbum.h"

@interface MMPDFInboxContentView ()<UIGestureRecognizerDelegate>

@end

@implementation MMPDFInboxContentView{
    NSMutableArray* pdfList;
    MMContinuousSwipeGestureRecognizer* deleteGesture;
    
    MMDisplayAssetGroupCell* swipeToDeleteCell;
    NSDate* recentDeleteSwipe;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pdfList = [NSMutableArray array];
        
        deleteGesture = [[MMContinuousSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGesture:)];
        deleteGesture.delegate = self;
        [albumListScrollView addGestureRecognizer:deleteGesture];
    }
    return self;
}


-(void) deleteGesture:(MMContinuousSwipeGestureRecognizer*)sender{
    CGPoint p = [sender locationInView:albumListScrollView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"start delete gesture: %f %f", p.x, p.y);
        NSIndexPath* indexPath = [albumListScrollView indexPathForItemAtPoint:p];
        swipeToDeleteCell = (MMDisplayAssetGroupCell*) [albumListScrollView cellForItemAtIndexPath:indexPath];
        albumListScrollView.clipsToBounds = NO;
    }else if(sender.state == UIGestureRecognizerStateChanged){
        CGFloat amount = -sender.distanceSinceBegin.x; // negative, because we're moving left
        [swipeToDeleteCell adjustForDelete:amount/100.0];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        recentDeleteSwipe = [NSDate date];
        NSLog(@"swipte gesture state: %d", (int) sender.state);
    }
    
    if(sender.state == UIGestureRecognizerStateEnded ||
       sender.state == UIGestureRecognizerStateCancelled){
        albumListScrollView.clipsToBounds = YES;
    }
}

-(void) switchToPDFView:(MMPDF*)pdf{
    __block NSInteger indexOfPDF = NSIntegerMax;
    
    [pdfList enumerateObjectsUsingBlock:^(MMPDFAlbum* obj, NSUInteger idx, BOOL *stop) {
        if(obj.pdf == pdf){
            indexOfPDF = idx;
            stop[0] = YES;
        }
    }];
    if(indexOfPDF < [pdfList count]){
        currentAlbum = [self albumAtIndex:indexOfPDF];
        photoListScrollView.contentOffset = CGPointZero;
        
        [photoListScrollView reloadData];
        
        albumListScrollView.alpha = 0;
        photoListScrollView.alpha = 1;
        albumListScrollView.hidden = YES;
    }
}

#pragma mark - MMAbstractSidebarContentView

-(void) reset:(BOOL)animated{
    [pdfList removeAllObjects];
    NSInteger count = [[MMInboxManager sharedInstance] itemsInInboxCount];
    for (int i=0; i<count; i++) {
        MMPDF* pdf = [[MMInboxManager sharedInstance] pdfItemAtIndex:i];
        [pdfList addObject:[[MMPDFAlbum alloc] initWithPDF:pdf]];
    }
    [albumListScrollView reloadData];
    [super reset:animated];
}


#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    return [pdfList indexOfObject:album];
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    return [pdfList objectAtIndex:index];
}

#pragma mark - MMCachedRowsScrollViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == albumListScrollView){
        return [[MMInboxManager sharedInstance] itemsInInboxCount];
    }else{
        return [super collectionView:collectionView numberOfItemsInSection:section];
    }
}


#pragma mark - Description

-(NSString*) description{
    return @"PDF Inbox";
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([recentDeleteSwipe timeIntervalSinceNow] > -0.3){
        // if we just did a swipe to delete, then don't select
        // that row
        return NO;
    }
    return YES;
}

@end
