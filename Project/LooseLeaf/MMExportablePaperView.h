//
//  MMExportablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBackgroundedPaperView.h"


@interface MMExportablePaperView : MMBackgroundedPaperView

@property (nonatomic, readonly) BOOL isCurrentlySaving;
@property (nonatomic, strong) void (^didUnloadState)();

- (void)exportAsynchronouslyToZipFile;

@end
