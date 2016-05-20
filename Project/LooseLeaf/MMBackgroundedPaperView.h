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

@end
