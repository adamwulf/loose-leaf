//
//  SLRenderManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/20/12.
//
//

#import "SLRenderManager.h"
#import "SLRenderManagerDelegate.h"
#import "SLBackingStoreManager.h"

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
        [self load];
    }
    return _instance;
}

+(SLRenderManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLRenderManager alloc] init];
    }
    return _instance;
}



/**
 * load in the NSDate's that we last rendered
 * each page's thumbnail
 */
-(void) load{
    [[SLBackingStoreManager sharedInstace].opQueue addOperationWithBlock:^{
        NSString* pathToRenderData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[@"render" stringByAppendingPathExtension:@"data"]];
        if([[NSFileManager defaultManager] fileExistsAtPath:pathToRenderData]){
            renderStamps = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:pathToRenderData]];
        }else{
            renderStamps = [[NSMutableDictionary dictionary] retain];
        }
     
    }];
}


-(void) renderThumbnailForPage:(SLPaperView*) page{
    if(page.lastModified){
        //
        // now check to see if our render date doesn't match
        // the last modified date of the page
        NSDate* dtOfRender = [renderStamps objectForKey:page.uuid];
        if(!dtOfRender || ![dtOfRender isEqualToDate:page.lastModified]){
            [renderStamps setObject:page.lastModified forKey:page.uuid];

            [[SLBackingStoreManager sharedInstace].opQueue addOperationWithBlock:^{
                //
                // only render if the page has been modified
                if(page.lastModified){
                    //
                    // now check to see if our render date doesn't match
                    // the last modified date of the page
                    NSDate* dtOfRender = [renderStamps objectForKey:page.uuid];
                    if(!dtOfRender || ![dtOfRender isEqualToDate:page.lastModified]){
                        @autoreleasepool {
                            NSLog(@"rendering thumbnail: %@", page.uuid);
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
                        }
                    }else{
                        // no change from last time, so send nil
//                        [page didGenerateThumbnail:nil forPage:page];
                    }
                }
            }];
            
        }
    }
}


-(void) didReceiveMemoryWarning{
    
}


@end
