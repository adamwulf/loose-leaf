//
//  MMPDFPage.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFPageAsset.h"
#import "MMPDFInboxItem.h"
#import <JotUI/UIImage+Resize.h>
#import "Constants.h"
#import "NSFileManager+DirectoryOptimizations.h"

@implementation MMPDFPageAsset{
    MMPDFInboxItem* pdfItem;
    NSInteger pageNumber;
    NSString* pagePDFPath;
}

static UIImage* lockThumbnail;

-(id) initWithPDF:(MMPDFInboxItem*)_pdf andPage:(NSInteger)_pageNum{
    if(self = [super init]){
        pdfItem = _pdf;
        pageNumber = _pageNum;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfThumbnailGenerated:) name:kInboxItemThumbnailGenerated object:pdfItem];
        
        [self generateLockIcon];
    }
    return self;
}

-(UIImage*) aspectRatioThumbnail{
    if(pdfItem.isEncrypted){
        return lockThumbnail;
    }
    return [pdfItem thumbnailForPage:pageNumber];
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    return [pdfItem imageForPage:pageNumber forMaxDim:maxDim];
}

-(CGSize) fullResolutionSize{
    if([pdfItem isEncrypted]){
        return lockThumbnail.size;
    }else{
        return [pdfItem sizeForPage:pageNumber];
    }
}

-(NSURL*) fullResolutionURL{
    if(!pagePDFPath || ![[NSFileManager defaultManager] fileExistsAtPath:pagePDFPath]){
        NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
        
        CGSize pageSize = [self fullResolutionSize];
        CGRect rect = CGRectMake(0, 0, pageSize.width, pageSize.height);
        CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:tmpPagePath]), &rect, NULL);
        CGPDFContextBeginPage(pdfContext, NULL);

        CGContextScaleCTM(pdfContext, 1, -1);
        CGContextTranslateCTM(pdfContext, 0, -pageSize.height);
    
        [pdfItem.pdf renderPage:pageNumber intoContext:pdfContext withSize:pageSize];
        
        CGPDFContextEndPage(pdfContext);
        CFRelease(pdfContext);
        
        pagePDFPath = tmpPagePath;
    }
    
    if(pagePDFPath && [[NSFileManager defaultManager] fileExistsAtPath:pagePDFPath]){
        return [NSURL fileURLWithPath:pagePDFPath];
    }
    return nil; // error generating a single page PDF
}

-(CGFloat) preferredImportMaxDim{
    return kPDFImportMaxDim;
}

#pragma mark - Notification

-(void) pdfThumbnailGenerated:(NSNotification*)obj{
    NSInteger updatedPageNumber = [[[obj userInfo] objectForKey:@"pageNumber"] integerValue];
    if(updatedPageNumber == pageNumber){
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisplayAssetThumbnailGenerated object:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Lock Icon

-(void) generateLockIcon{
    // make the lock icon
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect imageBounds = [[UIScreen mainScreen] bounds];
        if(imageBounds.size.width > imageBounds.size.height){
            // force portrait for lock page
            CGFloat oldW = imageBounds.size.width;
            imageBounds.size.width = imageBounds.size.height;
            imageBounds.size.height = oldW;
        }
        UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 1);
        CGContextRef cgContext = UIGraphicsGetCurrentContext();
        [[UIColor whiteColor] setFill];
        CGContextFillRect(cgContext, CGRectMake(0, 0, imageBounds.size.width, imageBounds.size.height));
        
        CGFloat dimMin = MIN(imageBounds.size.width, imageBounds.size.height);
        CGFloat lockWidth = dimMin/2;
        CGRect lockFrame = CGRectMake((imageBounds.size.width-lockWidth)/2, (imageBounds.size.height - lockWidth)/2, lockWidth, lockWidth);
        [self drawLockInFrame:lockFrame];

        lockThumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
}


-(void) drawLockInFrame:(CGRect)frame{
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.17403 - 0.25) + 0.75, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.00000 - 0.2) + 0.7, floor(CGRectGetWidth(frame) * 0.82517 - 0.05) - floor(CGRectGetWidth(frame) * 0.17403 - 0.25) - 0.2, floor(CGRectGetHeight(frame) * 1.00034 + 0.5) - floor(CGRectGetHeight(frame) * 0.00000 - 0.2) - 0.7);
    
    
    //// Group
    {
        //// Lock Top Drawing
        UIBezierPath* lockTopPath = UIBezierPath.bezierPath;
        [lockTopPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.72212 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.33195 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.85815 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38504 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.77134 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34551 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.81686 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.36332 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.85815 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.23153 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50265 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.85815 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.10387 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.69866 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.49718 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.14185 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.23153 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.30134 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.14185 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.10387 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.14185 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38504 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27788 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.33195 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.18313 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.36332 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.22865 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34551 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.31828 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32196 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.29111 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32828 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.30469 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32495 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.31828 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.23153 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49735 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.11490 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.31828 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.16718 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.39855 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.11490 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.50282 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.11490 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.68190 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.23153 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.60162 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.11490 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.68190 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.16718 * CGRectGetHeight(group))];
        [lockTopPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.68190 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32207 * CGRectGetHeight(group))];
        [lockTopPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.72212 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.33195 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.69530 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32495 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.70889 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.32828 * CGRectGetHeight(group))];
        [lockTopPath closePath];
        lockTopPath.miterLimit = 4;
        
        [UIColor.blackColor setFill];
        [lockTopPath fill];
        
        
        //// Lock Body Drawing
        UIBezierPath* lockBodyPath = UIBezierPath.bezierPath;
        [lockBodyPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.67437 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.85419 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.22389 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.67437 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.77611 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.85430 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.85815 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.44709 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.58601 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.94583 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50580 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.68172 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.37079 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.80875 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.41411 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.74877 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38791 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34862 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.62544 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35643 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.56404 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34862 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.31828 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.37079 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.43596 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.34862 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.37456 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35643 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.14185 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.44709 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.25124 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38780 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.19125 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.41400 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.67437 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.05399 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50580 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.58601 * CGRectGetHeight(group))];
        [lockBodyPath closePath];
        [lockBodyPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.37120 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.60864 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49682 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.52694 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.37297 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.56417 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.42854 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.52798 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.62879 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.61082 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.56933 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.52580 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.62879 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.56383 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.62685 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.62519 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.62879 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.61577 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.62808 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.62059 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.56845 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68183 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.62049 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.64897 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.59880 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.66942 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.55275 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.70596 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.55592 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68701 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.54957 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.69666 * CGRectGetHeight(group))];
        [lockBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.59104 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.82420 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.57374 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83810 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.59333 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83132 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.58504 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83810 * CGRectGetHeight(group))];
        [lockBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.42625 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83810 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.40896 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.82420 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.41496 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83810 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.40667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.83144 * CGRectGetHeight(group))];
        [lockBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.44725 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.70596 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.43154 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68172 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.45024 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.69654 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.44407 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68689 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.37315 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.62507 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.40120 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.66931 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.37950 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.64897 * CGRectGetHeight(group))];
        [lockBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.37120 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.60864 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.37173 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.61979 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.37103 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.61427 * CGRectGetHeight(group))];
        [lockBodyPath closePath];
        lockBodyPath.miterLimit = 4;
        
        [UIColor.blackColor setFill];
        [lockBodyPath fill];
    }
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
