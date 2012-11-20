//
//  SLRenderManagerDelegate.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/20/12.
//
//

#import <Foundation/Foundation.h>

@class SLPaperView;

@protocol SLRenderManagerDelegate <NSObject>

-(void) willGenerateThumbnailForPage:(SLPaperView*)page;

-(void) didGenerateThumbnail:(UIImage*)img forPage:(SLPaperView*)page;


@end
