//
//  MMJotViewNilState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <JotUI/JotUI.h>

@interface MMJotViewNilState : JotViewStateProxy

- (instancetype)init NS_UNAVAILABLE;

+(MMJotViewNilState*) sharedInstance;

@end
