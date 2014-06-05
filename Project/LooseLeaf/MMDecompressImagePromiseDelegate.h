//
//  MMDecompressImagePromiseDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMDecompressImagePromiseDelegate <NSObject>

-(void) didDecompressImage:(UIImage*)img;

@end
