//
//  MMPDFInboxContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxContentView.h"
#import "MMDisplayAssetGroupCell.h"
#import "MMContinuousSwipeGestureRecognizer.h"
#import "MMDisplayAssetGroupCellDelegate.h"
#import "MMPhotoManager.h"
#import "MMInboxManager.h"
#import "MMPDFAlbum.h"
#import "MMInboxAssetGroupCell.h"
#import "MMInboxListLayout.h"

@interface MMInboxContentView ()<UIGestureRecognizerDelegate,MMDisplayAssetGroupCellDelegate>

@end

@implementation MMInboxContentView{
    NSMutableArray* pdfList;
    MMContinuousSwipeGestureRecognizer* deleteGesture;
    
    CGFloat initialAdjustment;
    MMDisplayAssetGroupCell* swipeToDeleteCell;
    NSDate* recentDeleteSwipe;
    
    
    NSIndexPath* decryptingIndexPath;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pdfList = [NSMutableArray array];
        
        [albumListScrollView registerClass:[MMInboxAssetGroupCell class] forCellWithReuseIdentifier:@"MMPDFAssetGroupCell"];

        deleteGesture = [[MMContinuousSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGesture:)];
        deleteGesture.delegate = self;
        deleteGesture.angleBuffer = 30;
        [albumListScrollView addGestureRecognizer:deleteGesture];
        albumListScrollView.clipsToBounds = NO;
    }
    return self;
}

//
// immediately switch to show a PDF.
// this is useful when a user has just
// imported a PDF and we want to show the
// sidebar immediately w/o any animation
-(void) switchToPDFView:(MMInboxItem*)pdf{
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
        MMInboxItem* pdf = [[MMInboxManager sharedInstance] itemAtIndex:i];
        if([pdf isKindOfClass:[MMPDFInboxItem class]]){
            [pdfList addObject:[[MMPDFAlbum alloc] initWithPDF:(MMPDFInboxItem*)pdf]];
        }else if([pdf isKindOfClass:[MMInboxItem class]]){
            [pdfList addObject:[[MMInboxItem alloc] init]];
        }
    }
    [albumListScrollView reloadData];
    [super reset:animated];
}

-(UICollectionViewLayout*) albumsLayout{
    return [[MMInboxListLayout alloc] init];
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

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MMDisplayAssetGroupCell* cell;
    if(collectionView == albumListScrollView){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPDFAssetGroupCell" forIndexPath:indexPath];
        cell.album = [self albumAtIndex:indexPath.row];
    }else{
        cell = (MMDisplayAssetGroupCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    cell.delegate = self;
    if(collectionView == albumListScrollView){
        [cell resetDeleteAdjustment:NO];
    }
    return cell;
}


#pragma mark - Description

-(NSString*) description{
    return @"PDF Inbox";
}

#pragma mark - Delete Inbox Items

-(void) deleteGesture:(MMContinuousSwipeGestureRecognizer*)sender{
    CGPoint p = [sender locationInView:albumListScrollView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"start delete gesture: %f %f", p.x, p.y);
        NSIndexPath* indexPath = [albumListScrollView indexPathForItemAtPoint:p];
        swipeToDeleteCell = (MMDisplayAssetGroupCell*) [albumListScrollView cellForItemAtIndexPath:indexPath];
        initialAdjustment = swipeToDeleteCell.squishFactor;
        [[albumListScrollView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(obj != swipeToDeleteCell){
                [obj resetDeleteAdjustment:YES];
            }
        }];
        // don't let the user swipe and scroll at the same time
        albumListScrollView.scrollEnabled = NO;
    }else if(sender.state == UIGestureRecognizerStateChanged){
        CGFloat amount = -sender.distanceSinceBegin.x; // negative, because we're moving left
        [swipeToDeleteCell adjustForDelete:initialAdjustment + amount/100.0];
    }else if(sender.state == UIGestureRecognizerStateEnded ||
             sender.state == UIGestureRecognizerStateCancelled){
        albumListScrollView.scrollEnabled = YES;
        recentDeleteSwipe = [NSDate date];
        NSLog(@"swipe gesture state: %d", (int) sender.state);
        if([swipeToDeleteCell finishSwipeToDelete]){
            NSLog(@"delete immediately");
            
            [self deleteButtonWasTappedForCell:swipeToDeleteCell];
            
        }else{
            NSLog(@"don't delete, wait for tap");
        }
    }
}

#pragma mark - MMDisplayAssetGroupCellDelegate

-(void) deleteButtonWasTappedForCell:(MMDisplayAssetGroupCell *)cell{
    NSIndexPath* pathToDelete = [albumListScrollView indexPathForCell:swipeToDeleteCell];
    MMPDFAlbum* pdfAlbum = (MMPDFAlbum*) swipeToDeleteCell.album;
    [[MMInboxManager sharedInstance] removeInboxItem:pdfAlbum.pdf.urlOnDisk onComplete:^(BOOL hasErr){
        if(hasErr){
            NSLog(@"Error deleting PDF: %@", pdfAlbum.pdf.urlOnDisk);
            @throw [NSException exceptionWithName:@"DeletePDFException" reason:[NSString stringWithFormat:@"Error deleting pdf"] userInfo:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [albumListScrollView performBatchUpdates:^{
                [albumListScrollView deleteItemsAtIndexPaths:@[pathToDelete]];
            } completion:^(BOOL finished) {
                swipeToDeleteCell = nil;
                recentDeleteSwipe = nil;
            }];
        });
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(recentDeleteSwipe && [recentDeleteSwipe timeIntervalSinceNow] > -0.3){
        // if we just did a swipe to delete, then don't select
        // that row
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == albumListScrollView){
        MMPDFAlbum* pdfAlbum = (MMPDFAlbum*) [self albumAtIndex:indexPath.row];
        if(pdfAlbum.pdf.isEncrypted){
            decryptingIndexPath = indexPath;
            // ask for password
            UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"PDF is Encrypted" message:@"Please enter the password to view the PDF:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alertViewChangeName.delegate = self;
            alertViewChangeName.alertViewStyle=UIAlertViewStylePlainTextInput;
            [alertViewChangeName show];
        }else if(pdfAlbum.pdf.pageCount == 1){
            
            MMInboxAssetGroupCell* cell = [[albumListScrollView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                UICollectionViewCell* cell = evaluatedObject;
                return [[albumListScrollView indexPathForCell:cell] isEqual:indexPath];
            }]] firstObject];
            
            
            NSIndexSet* pageSet = [NSIndexSet indexSetWithIndex:0];
            [pdfAlbum loadPhotosAtIndexes:pageSet usingBlock:^(MMDisplayAsset *result, NSUInteger index, BOOL *stop) {
                [self photoWasTapped:result fromView:cell.firstImageView withRotation:0];
            }];
        }else{
            [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
        }
    }
}

#pragma mark - UIAlertViewDelete

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString* password = [[alertView textFieldAtIndex:0] text];
        NSLog(@"password: %@", password);
        
        MMPDFAlbum* pdfAlbum = (MMPDFAlbum*) [self albumAtIndex:decryptingIndexPath.row];
        if([pdfAlbum.pdf attemptToDecrypt:password]){
            NSLog(@"congrats");
            
            if([[albumListScrollView indexPathsForVisibleItems] containsObject:decryptingIndexPath]){
                // if the cell is already visible, then animate that cell to non-decrypted
                // otherwise nothing
                MMInboxAssetGroupCell* cell = [[albumListScrollView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    UICollectionViewCell* cell = evaluatedObject;
                    return [[albumListScrollView indexPathForCell:cell] isEqual:decryptingIndexPath];
                }]] firstObject];
                [UIView animateWithDuration:.3 animations:^{
                    cell.album = cell.album; // refresh
                }];
            }
        }else{
            UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"Incorrect Password" message:@"Please enter the password to view the PDF:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alertViewChangeName.delegate = self;
            alertViewChangeName.alertViewStyle=UIAlertViewStylePlainTextInput;
            [alertViewChangeName show];
        }
        
    }
    decryptingIndexPath = nil;
}
@end
