//
//  MMPDF.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMPDF : NSObject

@property (nonatomic, readonly) NSURL* urlOnDisk;
@property (nonatomic, readonly) NSUInteger pageCount;
@property (nonatomic, readonly) NSString* title;

// the ppi used for PDF contexts
+ (CGFloat)ppi;

- (instancetype)initWithURL:(NSURL*)url;

- (BOOL)attemptToDecrypt:(NSString*)password;

- (BOOL)isEncrypted;

- (CGSize)sizeForPage:(NSUInteger)page;

- (CGFloat)rotationForPage:(NSUInteger)page;

- (UIImage*)imageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim;

// must open the PDF before calling [renderPage:]
// info here: http://stackoverflow.com/questions/25129757/ios-crash-inside-uigraphicsbeginpdfpagewithinfo
// it has to do with the PDF document ref getting released /after/ the context that it's drawn into
- (CGPDFDocumentRef)openPDF;
-(void) closePDF;

- (void)renderPage:(NSUInteger)page intoContext:(CGContextRef)ctx withSize:(CGSize)size withPDFRef:(CGPDFDocumentRef)pdf;

@end
