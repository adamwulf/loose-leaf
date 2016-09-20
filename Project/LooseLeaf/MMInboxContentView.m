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
#import "MMPDFAssetGroup.h"
#import "MMInboxImageAlbum.h"
#import "MMInboxAssetGroupCell.h"
#import "MMAlbumGroupListLayout.h"
#import "MMDisplayAssetCell.h"
#import "NSArray+Extras.h"
#import "Constants.h"

@interface MMInboxContentView ()<UIGestureRecognizerDelegate,MMDisplayAssetGroupCellDelegate>

@end

@implementation MMInboxContentView{
    NSMutableDictionary* albumForInboxItem;
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
        albumForInboxItem = [NSMutableDictionary dictionary];
        
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
    __block NSInteger indexOfPDF = [[MMInboxManager sharedInstance] indexOfItem:pdf];

    if(indexOfPDF != NSNotFound){
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
    NSInteger count = [[MMInboxManager sharedInstance] itemsInInboxCount];
    NSMutableArray* allSeenURLs = [NSMutableArray array];
    NSMutableArray* changedIndexPaths = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        MMInboxItem* inboxItem = [[MMInboxManager sharedInstance] itemAtIndex:i];
        if(![albumForInboxItem objectForKey:inboxItem.urlOnDisk]){
            // that index was added
            [changedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self albumAtIndex:i];
        [allSeenURLs addObject:inboxItem.urlOnDisk];
    }
    
    // remove any old objects from the cache
    NSArray* unseenURLs = [[albumForInboxItem allKeys] arrayByRemovingObjectsInArray:allSeenURLs];
    [albumForInboxItem removeObjectsForKeys:unseenURLs];

    NSAssert(![unseenURLs count], @"why do i need to remove objects from cache? this should've been done when the item was deleted.... %d", (int)[unseenURLs count]);
    
    [albumListScrollView reloadData];
    [super reset:animated];
}

-(NSString*) messageTextWhenEmpty{
    return @"Import PDFs and Images from other apps";
}


#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMDisplayAssetGroup*)album{
    MMInboxAssetGroup* inboxGroup = (MMInboxAssetGroup*) album;
    NSInteger count = [[MMInboxManager sharedInstance] itemsInInboxCount];
    for (NSInteger i=0; i<count; i++) {
        MMInboxItem* inboxItem = [[MMInboxManager sharedInstance] itemAtIndex:i];
        if([inboxItem.urlOnDisk isEqual:inboxGroup.inboxItem.urlOnDisk]){
            return i;
        }
    }
    @throw [NSException exceptionWithName:@"InternalInconsistencyException" reason:@"asking for inbox item that does not exist" userInfo:nil];
}

-(MMDisplayAssetGroup*) albumAtIndex:(NSInteger)index{
    MMInboxItem* inboxItem = [[MMInboxManager sharedInstance] itemAtIndex:index];
    MMInboxAssetGroup* assetGroup = [albumForInboxItem objectForKey:inboxItem.urlOnDisk];
    if(!assetGroup){
        // asset is not in cache, create it
        if([inboxItem isKindOfClass:[MMPDFInboxItem class]]){
            assetGroup = [[MMPDFAssetGroup alloc] initWithInboxItem:(MMPDFInboxItem*)inboxItem];
        }else if([inboxItem isKindOfClass:[MMInboxItem class]]){
            assetGroup = [[MMInboxImageAlbum alloc] initWithInboxItem:inboxItem];
        }
        if(assetGroup){
            [albumForInboxItem setObject:assetGroup forKey:inboxItem.urlOnDisk];
        }
    }
    
    return assetGroup;
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
    if([cell respondsToSelector:@selector(updatePhotoRotation)]){
        [cell updatePhotoRotation];
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

        if([swipeToDeleteCell finishSwipeToDelete]){
            // delete immediately
            [self deleteButtonWasTappedForCell:swipeToDeleteCell];
        }else{
            // don't delete, wait for tap
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletingInboxItemGesture object:sender];
}

#pragma mark - MMDisplayAssetGroupCellDelegate

-(void) deleteButtonWasTappedForCell:(MMDisplayAssetGroupCell *)cell{
    NSIndexPath* pathToDelete = [albumListScrollView indexPathForCell:swipeToDeleteCell];
    MMInboxAssetGroup* pdfAlbum = (MMInboxAssetGroup*) swipeToDeleteCell.album;
    dispatch_async(dispatch_get_main_queue(), ^{
        [albumListScrollView performBatchUpdates:^{
            [[MMInboxManager sharedInstance] removeInboxItem:pdfAlbum.inboxItem.urlOnDisk onComplete:^(BOOL hasErr){
                if(hasErr){
                    @throw [NSException exceptionWithName:@"DeletePDFException" reason:[NSString stringWithFormat:@"Error deleting pdf"] userInfo:nil];
                }
            }];
            [albumForInboxItem removeObjectForKey:pdfAlbum.inboxItem.urlOnDisk];
            [albumListScrollView deleteItemsAtIndexPaths:@[pathToDelete]];
        } completion:^(BOOL finished) {
            swipeToDeleteCell = nil;
            recentDeleteSwipe = nil;
            [self reset:NO];
        }];
    });
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

-(MMInboxAssetGroupCell*) visibleCellAtIndexPath:(NSIndexPath*)indexPath{
    return [[albumListScrollView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        UICollectionViewCell* cell = evaluatedObject;
        return [[albumListScrollView indexPathForCell:cell] isEqual:indexPath];
    }]] firstObject];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == albumListScrollView){
        MMInboxAssetGroup* pdfAlbum = (MMInboxAssetGroup*) [self albumAtIndex:indexPath.row];
        MMPDFInboxItem* pdfItem = (MMPDFInboxItem*) ([pdfAlbum isKindOfClass:[MMPDFAssetGroup class]] ? pdfAlbum.inboxItem : nil);
        if([pdfItem isEncrypted]){
            decryptingIndexPath = indexPath;
            // ask for password
            UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"PDF is Encrypted" message:@"Please enter the password to view the PDF:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alertViewChangeName.delegate = self;
            alertViewChangeName.alertViewStyle=UIAlertViewStyleSecureTextInput;
            [alertViewChangeName show];
        }else if(pdfAlbum.inboxItem.pageCount == 1){
            
            MMInboxAssetGroupCell* cell = [self visibleCellAtIndexPath:indexPath];
            
            NSIndexSet* pageSet = [NSIndexSet indexSetWithIndex:0];
            [pdfAlbum loadPhotosAtIndexes:pageSet usingBlock:^(MMDisplayAsset *result, NSUInteger index, BOOL *stop) {
                [self assetWasTapped:result fromView:cell.firstImageView withRotation:0];
            }];
        }else{
            MMInboxAssetGroupCell* cell = [self visibleCellAtIndexPath:indexPath];
            
            if(cell.squishFactor){
                [cell resetDeleteAdjustment:YES];
            }else{
                [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIAlertViewDelete

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString* password = [[alertView textFieldAtIndex:0] text];
        
        MMPDFAssetGroup* pdfAlbum = (MMPDFAssetGroup*) [self albumAtIndex:decryptingIndexPath.row];
        MMPDFInboxItem* pdfItem = (MMPDFInboxItem*) ([pdfAlbum isKindOfClass:[MMPDFAssetGroup class]] ? pdfAlbum.inboxItem : nil);
        if([pdfItem attemptToDecrypt:password]){
            if([[albumListScrollView indexPathsForVisibleItems] containsObject:decryptingIndexPath]){
                // if the cell is already visible, then animate that cell to non-decrypted
                // otherwise nothing
                MMInboxAssetGroupCell* cell = [self visibleCellAtIndexPath:decryptingIndexPath];
                [UIView animateWithDuration:.3 animations:^{
                    cell.album = cell.album; // refresh
                }];
            }
        }else{
            UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:@"Incorrect Password" message:@"Please enter the password to view the PDF:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alertViewChangeName.delegate = self;
            alertViewChangeName.alertViewStyle=UIAlertViewStyleSecureTextInput;
            [alertViewChangeName show];
        }
    }
    decryptingIndexPath = nil;
}
@end
