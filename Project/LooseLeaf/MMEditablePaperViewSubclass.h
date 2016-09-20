//
//  MMEditablePaperViewSubclass.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#ifndef LooseLeaf_MMEditablePaperViewSubclass_h
#define LooseLeaf_MMEditablePaperViewSubclass_h


@interface MMEditablePaperView (Subclass)

+ (dispatch_queue_t)importThumbnailQueue;

- (void)saveToDiskHelper:(void (^)(BOOL didSaveEdits))onComplete;

- (void)updateThumbnailVisibility:(BOOL)forceUpdateIconImage;

@end

#endif
