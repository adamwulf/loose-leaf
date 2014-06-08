//
//  MMPDF.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMPDF : NSObject

-(id) initWithURL:(NSURL*)pdfURL;

-(NSUInteger) pageCount;

@end
