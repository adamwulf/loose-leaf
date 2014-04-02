//
//  MMPhotoRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoRowView.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMBufferedImageView.h"

@implementation MMPhotoRowView{
    MMBufferedImageView* leftImageView;
    MMBufferedImageView* rightImageView;
    
    MMPhotoAlbum* loadedAlbum;
    NSInteger loadedIndex;
    
    ALAsset* leftAsset;
    ALAsset* rightAsset;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat maxDim = self.bounds.size.height;

        leftImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, maxDim, maxDim), 2, 2)];
        leftImageView.rotation = RandomPhotoRotation;
        [self addSubview:leftImageView];

        rightImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(self.bounds.size.width - maxDim, 0, maxDim, maxDim), 2, 2)];
        rightImageView.rotation = RandomPhotoRotation;
        [self addSubview:rightImageView];

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
        
//        leftImageView.layer.borderColor = [UIColor orangeColor].CGColor;
//        leftImageView.layer.borderWidth = 1;
//        
//        rightImageView.layer.borderColor = [UIColor purpleColor].CGColor;
//        rightImageView.layer.borderWidth = 1;
//        
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth = 1;
    }
    return self;
}


-(void) loadPhotosFromAlbum:(MMPhotoAlbum*)album atRow:(NSInteger)rowIndex{
    if(loadedAlbum != album || loadedIndex != rowIndex){
        loadedAlbum = album;
        loadedIndex = rowIndex;
        
        // now flip the index so we load
        // in reverse order
        NSInteger numberOfPhotos = album.numberOfPhotos;
        NSInteger numberOfRows = ceilf(numberOfPhotos / 2.0);
        NSInteger indexOfLastRow = numberOfRows - 1;
        rowIndex = indexOfLastRow - rowIndex;
        if(!loadedAlbum){
            leftImageView.hidden = YES;
            rightImageView.hidden = YES;
            leftAsset = nil;
            rightAsset = nil;
        }else{
            NSIndexSet* assetsToLoad = nil;
            if(rowIndex >= ceilf(numberOfPhotos / 2.0) || rowIndex < 0){
                leftImageView.image = nil;
                rightImageView.image = nil;
                rightImageView.hidden = YES;
                leftImageView.hidden = YES;
                leftAsset = nil;
                rightAsset = nil;
            }else{
                leftImageView.hidden = NO;
                
                // num images = 4
                // num rows = 2
                // rowIndex = 0
                // trueRow = (2 - 1) - rowIndex
                // index = 2,3
                //
                // num images = 4
                // num rows = 2
                // rowIndex = 1
                // index = 0,1
                //
                // num images = 3
                // num rows = 2
                // row index = 0
                // index = 1,2
                // album.numberOfPhotos - index*2
                //
                // num images = 3
                // num rows = 2
                // rowIndex = 1
                // index = 0
                
                NSInteger leftIndex = rowIndex*2;
                if(numberOfPhotos % 2 == 0){
                    // if we're even, then add one
                    leftIndex += 1;
                }
                NSInteger rightIndex = leftIndex - 1;
                if(rightIndex < 0) rightIndex = leftIndex;
                
                if(rightIndex == leftIndex){
                    // we only show 1 photo
                    assetsToLoad = [[NSIndexSet alloc] initWithIndex:leftIndex];
                    rightImageView.hidden = YES;
                    rightAsset = nil;
                }else{
                    // we show 2 photos
                    assetsToLoad = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(rightIndex, 2)];
                    rightImageView.hidden = NO;
                }
                leftImageView.image = nil;
                leftImageView.tag = leftIndex;
                rightImageView.image = nil;
                rightImageView.tag = rightIndex;
                [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result){
                        if(index == leftIndex || [assetsToLoad count] == 1){
                            leftImageView.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                            leftImageView.hidden = NO;
                            leftAsset = result;
                        }else{
                            rightImageView.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                            rightImageView.hidden = NO;
                            rightAsset = result;
                        }
                    }
                }];
            }
        }
    }
}

-(void) unload{
    loadedAlbum = nil;
    loadedIndex = 0;
    leftImageView.image = nil;
    rightImageView.image = nil;
    leftImageView.hidden = YES;
    rightImageView.hidden = YES;
}

#pragma mark UIGestureRecgonizer

-(void) tapped:(UIGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateRecognized){
        if([gesture locationInView:self].x < self.bounds.size.width/2){
            // tapped left
            [self.delegate photoRowWasTapped:self forAsset:leftAsset forImage:leftImageView];
            leftImageView.hidden = YES;
        }else{
            // tapped right
            [self.delegate photoRowWasTapped:self forAsset:rightAsset forImage:rightImageView];
            rightImageView.hidden = YES;
        }
    }
}

@end
