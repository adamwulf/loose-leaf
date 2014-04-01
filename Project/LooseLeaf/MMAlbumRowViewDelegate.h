//
//  MMAlbumRowViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMAlbumRowView;

@protocol MMAlbumRowViewDelegate <NSObject>

-(void) rowWasTapped:(MMAlbumRowView*)row;

@end
