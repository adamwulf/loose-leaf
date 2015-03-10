//
//  MMPDFAssetGroupCel.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFAssetGroupCell.h"
#import "MMPDFAlbum.h"
#import "MMBufferedImageView.h"
#import "Constants.h"

@interface MMDisplayAssetGroupCell (Protected)

-(void) initializePositionsForPreviewPhotos;
-(MMBufferedImageView*) previewViewForImage:(int)i;

@end

@implementation MMPDFAssetGroupCell

-(MMBufferedImageView*) firstImageView{
    return [[self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[MMBufferedImageView class]] && [evaluatedObject image];
    }]] lastObject];
}

-(void) setAlbum:(MMDisplayAssetGroup *)_album{
    if(album){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPDFThumbnailGenerated object:album];
    }
    [super setAlbum:_album];
    if(![_album isKindOfClass:[MMPDFAlbum class]]){
        @throw [NSException exceptionWithName:@"PDFAssetGroupCellException" reason:@"Cell can only show PDFs" userInfo:nil];
    }
    [self initializePositionsForPreviewPhotos];
    MMPDFAlbum* pdfAlbum = (MMPDFAlbum*)album;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previewUpdated:) name:kPDFThumbnailGenerated object:pdfAlbum.pdf];
}

-(void) previewUpdated:(NSNotification*) note{
    if([[note.userInfo objectForKey:@"pageNumber"] integerValue] < 5){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadedPreviewPhotos];
        });
    }
}

-(void) initializePositionsForPreviewPhotos{
    MMPDFAlbum* pdfAlbum = (MMPDFAlbum*)self.album;
    if(pdfAlbum.pdf.isEncrypted){
        // center views in cell
        CGFloat halfWidth = self.bounds.size.width/2;
        CGFloat maxDim = self.bounds.size.height;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [self previewViewForImage:i];
            imgView.bounds = CGRectMake(0, 0, maxDim, maxDim);

            CGFloat randRot = RandomPhotoRotation(i);
            imgView.rotation = randRot;
            CGFloat extra = i == 0 ? 0 : RandomMod(i, 9)-4;
            imgView.center = CGPointMake(halfWidth + kBounceWidth + extra, maxDim/2);
            initialX[5-i-1] = imgView.center.x;
            finalX[5-i-1] = halfWidth - 80;
            initRot[5-i-1] = randRot;
            rotAdj[5-i-1] = RandomPhotoRotation(i+1);
            adjY[5-i-1] = (4 + rand()%4) * (i%2 ? 1 : -1);
            
        }
    }else{
        // spread out preview images
        [super initializePositionsForPreviewPhotos];
    }
}

-(void) prepareForReuse{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
