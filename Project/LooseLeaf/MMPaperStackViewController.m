//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackViewController.h"
#import "MMShadowManager.h"
#import "MMEditablePaperView.h"

@interface MMLooseLeafViewController ()

@end

@implementation MMLooseLeafViewController

- (id)init{
    if(self = [super init]){
        // Do any additional setup after loading the view, typically from a nib.
        srand ( time(NULL) );
        [[MMShadowManager sharedInstace] beginGeneratingShadows];
    
        self.view.opaque = YES;
        
        stackView = [[MMEditablePaperStackView alloc] initWithFrame:self.view.frame];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:stackView];
        
        [stackView loadStacksFromDisk];
        
        if(![stackView hasPages]){
            for(int i=0;i<1;i++){
                MMEditablePaperView* editable = [[MMEditablePaperView alloc] initWithFrame:self.view.bounds];
                [editable setEditable:YES];
                [stackView addPaperToBottomOfStack:editable];
                MMPaperView* paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
                [stackView addPaperToBottomOfStack:paper];
                paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
                [stackView addPaperToBottomOfHiddenStack:paper];
                paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
                [stackView addPaperToBottomOfHiddenStack:paper];
            }
            [stackView saveStacksToDisk];
        }
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cloth.png"]]];

        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}



@end
