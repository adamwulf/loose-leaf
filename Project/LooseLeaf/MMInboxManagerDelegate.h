//
//  MMInboxManagerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPDFInboxItem.h"
#import "MMImageInboxItem.h"

@protocol MMInboxManagerDelegate <NSObject>

- (void)didProcessIncomingImage:(MMImageInboxItem*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication;

- (void)didProcessIncomingPDF:(MMPDFInboxItem*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication;

- (void)failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication;

@end
