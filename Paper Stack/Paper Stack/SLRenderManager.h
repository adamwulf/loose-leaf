//
//  SLRenderManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/20/12.
//
//

#import <Foundation/Foundation.h>
#import "SLRenderManagerDelegate.h"
#import "SLPaperView.h"

@interface SLRenderManager : NSObject{
    NSOperationQueue* opQueue;

    NSObject<SLRenderManagerDelegate>* delegate;
    
    NSMutableDictionary* renderStamps;
}

@property (nonatomic, readonly) NSOperationQueue* opQueue;
@property (nonatomic, assign) NSObject<SLRenderManagerDelegate>* delegate;

+(SLRenderManager*) sharedInstace;

-(void) renderThumbnailForPage:(SLPaperView*) page;

-(void) didReceiveMemoryWarning;

@end
