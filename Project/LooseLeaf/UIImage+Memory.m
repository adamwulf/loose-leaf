//
//  UIImage+Memory.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIImage+Memory.h"


@implementation UIImage (Memory)

- (int)uncompressedByteSize {
    return self.size.width * self.scale * self.size.height * self.scale * 4;
}

@end
