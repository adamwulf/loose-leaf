//
//  MMStackManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMStackManager.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Map.h"

@implementation MMStackManager

-(id) initWithVisibleStack:(MMPaperStackView*)_visibleStack andHiddenStack:(MMPaperStackView*)_hiddenStack andBezelStack:(MMPaperStackView*)_bezelStack{
    if(self = [super init]){
        visibleStack = _visibleStack;
        hiddenStack = _hiddenStack;
        bezelStack = _bezelStack;
    }
    return self;
}


-(void) saveToDisk{
    [NSThread performBlockOnMainThread:^{
        // must use main thread to get the stack
        // of UIViews to save to disk
        
        NSArray* visiblePages = [NSArray arrayWithArray:visibleStack.subviews];
        NSMutableArray* hiddenPages = [NSMutableArray arrayWithArray:hiddenStack.subviews];
        NSMutableArray* bezelPages = [NSMutableArray arrayWithArray:bezelStack.subviews];
        while([bezelPages count]){
            id obj = [bezelPages lastObject];
            [hiddenPages addObject:obj];
            [bezelPages removeLastObject];
        }
        
        [NSThread performBlockInBackground:^{
            // now that we have the views to save,
            // we can actually write to disk on the background

            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentsPath = [paths objectAtIndex:0];
            NSString* visiblePlistPath = [[documentsPath stringByAppendingPathComponent:@"visiblePages"] stringByAppendingPathExtension:@"plist"];
            NSString* hiddenPlistPath = [[documentsPath stringByAppendingPathComponent:@"hiddenPages"] stringByAppendingPathExtension:@"plist"];
            
            NSArray* visiblePagesToWrite = [visiblePages mapObjectsUsingSelector:@selector(dictionaryDescription)];
            NSArray* hiddenPagesToWrite = [hiddenPages mapObjectsUsingSelector:@selector(dictionaryDescription)];
            
            [visiblePagesToWrite writeToFile:visiblePlistPath atomically:YES];
            [hiddenPagesToWrite writeToFile:hiddenPlistPath atomically:YES];
            
            NSLog(@"visible: %@\n %@", visiblePlistPath, visiblePages);
            NSLog(@"hidden: %@\n %@", hiddenPlistPath, hiddenPages);
        }];
    }];
}

@end
