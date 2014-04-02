//
//  MMPhotoRowView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPhotoAlbum.h"

@interface MMPhotoRowView : UIView

-(void) loadPhotosFromAlbum:(MMPhotoAlbum*)album atRow:(NSInteger)rowIndex;

-(void) unload;

@end
