//
//  MMMirrorButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"

typedef enum : NSInteger {
    MirrorModeNone = 0,
    MirrorModeVertical,
    MirrorModeHorizontal
} MirrorMode;


@interface MMMirrorButton : MMSidebarButton

@property (nonatomic, assign) MirrorMode mirrorMode;

-(void) cycleMirrorMode;

@end
