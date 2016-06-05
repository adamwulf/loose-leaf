//
//  MMBackgroundedPaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/25/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoablePaperView.h"

@interface MMBackgroundedPaperView : MMUndoablePaperView

-(UIImage*) pageBackgroundTexture;

-(void) setPageBackgroundTexture:(UIImage*)img;

// saves the file at the input URL as the background's original
// asset file. This is useful for a background that is set as
// a UIImage but was generated from a PDF
-(void) saveOriginalBackgroundTextureFromURL:(NSURL*)originalAssetURL;

-(void) exportToPDF:(void(^)(NSURL* urlToPDF))completionBlock;

@end
