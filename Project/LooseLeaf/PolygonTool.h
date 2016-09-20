//
//  PolygonTool.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "Tool.h"
#import "PolygonToolDelegate.h"


@interface PolygonTool : Tool {
    NSObject<PolygonToolDelegate>* __weak delegate;
}

@property (nonatomic, weak) NSObject<PolygonToolDelegate>* delegate;

- (void)cancelPolygonForTouch:(UITouch*)touch;

- (void)cancelAllTouches;

@end
