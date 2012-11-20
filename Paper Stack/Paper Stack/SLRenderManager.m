//
//  SLRenderManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/20/12.
//
//

#import "SLRenderManager.h"
#import "SLRenderManagerDelegate.h"

@implementation SLRenderManager

@synthesize delegate;
@synthesize opQueue;

static SLRenderManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
        opQueue.name = @"SLRenderManager Queue";
    }
    return _instance;
}

+(SLRenderManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLRenderManager alloc] init];
    }
    return _instance;
}


-(void) renderThumbnailForPage:(SLPaperView*) page{
    [opQueue addOperationWithBlock:^{
        
        //
        // notify the page that we're about to generate its thumbnail
        [page willGenerateThumbnailForPage:page];
        
        //
        // determine how large a thumbnail we need
        // multiply by 2 so that it can still look ok as we zoom from thumbnail to full page view
        CGRect thumbnailBounds = CGRectZero;
        CGSize thumbnailSize = CGSizeMake(page.initialPageSize.width * kListPageZoom * 2,
                                          page.initialPageSize.height * kListPageZoom * 2);
        thumbnailBounds.size = thumbnailSize;
        
        //
        // create the context, and make sure to support
        // high resolution screens
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationLow);
        
        //
        // ok, our canvas is ready,
        // draw the page as it told us to
        NSArray* blocks = [page arrayOfBlocksForDrawing];
        for(void (^ aBlock)(CGContextRef context, CGRect bounds) in blocks){
            aBlock(context, thumbnailBounds);
        }

        //
        // drawing is done, export to image
        UIImage* smallImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //
        // save image data
        NSData* imageData = UIImagePNGRepresentation(smallImg);
        NSString* pathToThumbnail = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[page.uuid stringByAppendingPathExtension:@"png"]];
        [imageData writeToFile:pathToThumbnail atomically:YES];

        //
        // notify the page that we're done with the thumbnail
        [page didGenerateThumbnail:smallImg forPage:page];
    }];

}


-(void) didReceiveMemoryWarning{
    
}


@end
