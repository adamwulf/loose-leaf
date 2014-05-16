//
//  MMStackManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperStackView.h"

@interface MMStackManager : NSObject{
    UIView* visibleStack;
    UIView* bezelStack;
    UIView* hiddenStack;
    
    
    NSOperationQueue* opQueue;
}

-(id) initWithVisibleStack:(UIView*)_visibleStack andHiddenStack:(UIView*)_hiddenStack andBezelStack:(UIView*)_bezelStack;

-(void) saveStacksToDisk;

-(NSDictionary*) loadFromDiskWithBounds:(CGRect)bounds;

@end
