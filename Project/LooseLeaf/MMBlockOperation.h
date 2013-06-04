//
//  MMBlockOperation.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMBlockOperation : NSOperation{

@private
    void (^_block)();
    
}

- (id) initWithBlock: (void (^)()) block;

@end
