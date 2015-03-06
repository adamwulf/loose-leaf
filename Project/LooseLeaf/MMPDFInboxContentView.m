//
//  MMPDFInboxContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFInboxContentView.h"
#import "MMPhotoManager.h"
#import "MMInboxManager.h"
#import "MMPDFAlbum.h"

@implementation MMPDFInboxContentView{
    NSMutableArray* pdfList;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pdfList = [NSMutableArray array];
    }
    return self;
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
@end
