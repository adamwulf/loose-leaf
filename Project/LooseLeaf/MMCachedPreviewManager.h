//
//  MMCachedPreviewManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCachedPreviewManager : NSObject

+(MMCachedPreviewManager*) sharedInstance;

-(UIImageView*) requestCachedImageViewForView:(UIView*)aView;

-(void) giveBackCachedImageView:(UIImageView*)imageView;

@end
