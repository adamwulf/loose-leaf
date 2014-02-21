//
//  MMShapeViewController.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMShapeViewController.h"
#import "MMStretchGestureRecognizer.h"

@implementation MMShapeViewController{
    UIView* draggable;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    draggable = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
    draggable.layer.borderWidth = 2;
    draggable.layer.borderColor = [UIColor blueColor].CGColor;
    
    [draggable addGestureRecognizer:[[MMStretchGestureRecognizer alloc] initWithTarget:self action:@selector(didStretch:)]];
    
    [self.view addSubview:draggable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didStretch:(MMStretchGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        NSLog(@"began");
    }else if(gesture.state == UIGestureRecognizerStateCancelled){
        NSLog(@"cancelled");
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        NSLog(@"changed");
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"ended");
    }else if(gesture.state == UIGestureRecognizerStateFailed){
        NSLog(@"failed");
    }else if(gesture.state == UIGestureRecognizerStatePossible){
        NSLog(@"possible");
    }else if(gesture.state == UIGestureRecognizerStateRecognized){
        NSLog(@"recognzied");
    }
}

@end
