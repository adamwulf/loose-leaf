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

#pragma mark - MMAbstractSidebarContentView

-(void) reset:(BOOL)animated{
    [pdfList removeAllObjects];
    NSInteger count = [[MMInboxManager sharedInstance] itemsInInboxCount];
    for (int i=0; i<count; i++) {
        MMPDF* pdf = [[MMInboxManager sharedInstance] pdfItemAtIndex:i];
        [pdfList addObject:[[MMPDFAlbum alloc] initWithPDF:pdf]];
    }
}


#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    return [pdfList indexOfObject:album];
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    return [pdfList objectAtIndex:index];
}

#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        // list of pdfs
        return [[MMInboxManager sharedInstance] itemsInInboxCount];
    }else{
        // return # of pages for selected pdf
        return 0;
    }
}

-(BOOL) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super prepareRowForReuse:aRow forScrollView:scrollView];
}

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super updateRow:currentRow atIndex:index forFrame:frame forScrollView:scrollView];
}


#pragma mark - Description

-(NSString*) description{
    return @"PDF Inbox";
}
@end
