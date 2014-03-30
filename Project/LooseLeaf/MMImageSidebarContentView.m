//
//  MMImageSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMPhotoAlbumListScrollView.h"
#import "MMAlbumRowView.h"

@implementation MMImageSidebarContentView{
    MMPhotoAlbumListScrollView* scrollView;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [MMPhotoManager sharedInstace].delegate = self;
        scrollView = [[MMPhotoAlbumListScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scrollView];
    }
    return self;
}


-(void) show:(BOOL)animated{
    NSLog(@"loading photos");
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
}

-(void) hide:(BOOL)animated{

}



#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGRect rect = self.bounds;
    rect.origin.y = 50;
    rect.size.height = self.bounds.size.width / 3;
    for (MMPhotoAlbum* album in [[MMPhotoManager sharedInstace] albums]) {
        MMAlbumRowView* row = [[MMAlbumRowView alloc] initWithFrame:rect andAlbum:album];
        [scrollView addSubview:row];
        rect.origin.y += rect.size.height;
    }

    for (MMPhotoAlbum* album in [[MMPhotoManager sharedInstace] events]) {
        MMAlbumRowView* row = [[MMAlbumRowView alloc] initWithFrame:rect andAlbum:album];
        [scrollView addSubview:row];
        rect.origin.y += rect.size.height;
    }

    for (MMPhotoAlbum* album in [[MMPhotoManager sharedInstace] faces]) {
        MMAlbumRowView* row = [[MMAlbumRowView alloc] initWithFrame:rect andAlbum:album];
        [scrollView addSubview:row];
        rect.origin.y += rect.size.height;
    }
    
    scrollView.contentSize = CGSizeMake(self.bounds.size.width, rect.origin.y + 50);
}


@end
