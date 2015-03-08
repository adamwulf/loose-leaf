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


-(void) setAlbum:(MMDisplayAssetGroup *)_album{
    [super setAlbum:_album];
    if(![_album isKindOfClass:[MMPDFAlbum class]]){
        @throw [NSException exceptionWithName:@"PDFAssetGroupCellException" reason:@"Cell can only show PDFs" userInfo:nil];
    }
    [self initializePositionsForPreviewPhotos];
}

-(void) initializePositionsForPreviewPhotos{
    MMPDFAlbum* pdfAlbum = (MMPDFAlbum*)self.album;
    if(pdfAlbum.pdf.isEncrypted){
        // center views in cell
        CGFloat halfWidth = self.bounds.size.width/2;
        CGFloat maxDim = self.bounds.size.height;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [self previewViewForImage:i];
            imgView.frame = CGRectMake(halfWidth - imgView.bounds.size.width/2, 0, maxDim, maxDim);

            CGFloat randRot = RandomPhotoRotation(i);
            imgView.rotation = randRot;
            initialX[5-i-1] = halfWidth + kBounceWidth;
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



@end
