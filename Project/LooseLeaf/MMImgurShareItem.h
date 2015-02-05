//
//  MMImgurShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"
#import "MMImageViewButton.h"

@interface MMImgurShareItem : NSObject<MMShareItem>{
    MMImageViewButton* button;
}

@end
