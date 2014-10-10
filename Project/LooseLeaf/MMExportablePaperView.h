//
//  MMExportablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoablePaperView.h"

@interface MMExportablePaperView : MMUndoablePaperView

@property (nonatomic, readonly) NSDictionary* cloudKitSenderInfo;
@property (nonatomic, readonly) BOOL isCurrentlySaving;

-(void) exportAsynchronouslyToZipFile;

@end
