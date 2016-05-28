//
//  MMPDF.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFInboxItem.h"
#import "MMLoadImageCache.h"
#import "Constants.h"
#import "MMInboxItem+Protected.h"
#import "MMPDF.h"

@implementation MMPDFInboxItem

@synthesize pdf;

#pragma mark - Init

-(id) initWithURL:(NSURL*)pdfURL{
    if(self = [super initWithURL:pdfURL andInitBlock:^{
        pdf = [[MMPDF alloc] initWithURL:pdfURL];
    }]){
        // noop
    }
    return self;
}

#pragma mark - Properties

-(BOOL) attemptToDecrypt:(NSString*)_password{
    return [pdf attemptToDecrypt:_password];
}

-(BOOL) isEncrypted{
    return [pdf isEncrypted];
}

#pragma mark - Override

-(NSUInteger) pageCount{
    
    return [pdf pageCount];
}

-(CGSize) calculateSizeForPage:(NSUInteger)page{
    return [pdf sizeForPage:page];
}

#pragma mark - Private

#pragma mark Scaled Image Generation

-(void) generatePageThumbnailCache{
    if(!self.isEncrypted){
        [super generatePageThumbnailCache];
    }
}

-(UIImage*) generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    return [pdf imageForPage:page withMaxDim:maxDim];
}


@end
