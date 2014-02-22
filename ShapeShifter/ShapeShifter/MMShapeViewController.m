//
//  MMShapeViewController.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMShapeViewController.h"
#import "MMStretchGestureRecognizer.h"
#import "Constants.h"

@implementation MMShapeViewController{
    UIImageView* draggable;
    
    UIView* ul;
    UIView* ur;
    UIView* br;
    UIView* bl;
    
    CGPoint adjust;
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
    
    UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 50, 300, 40)];
    [slider addTarget:self action:@selector(didChangeTo:) forControlEvents:UIControlEventValueChanged];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    slider.value = 0;
    
    draggable = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 300, 200)];
    draggable.contentMode = UIViewContentModeScaleAspectFill;
    draggable.clipsToBounds = YES;
    draggable.image = [UIImage imageNamed:@"space.jpg"];

    
    ul = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ul.backgroundColor = [UIColor redColor];
    ur = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ur.backgroundColor = [UIColor redColor];
    br = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    br.backgroundColor = [UIColor redColor];
    bl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    bl.backgroundColor = [UIColor redColor];

    
    [draggable addGestureRecognizer:[[MMStretchGestureRecognizer alloc] initWithTarget:self action:@selector(didStretch:)]];
    
    [self.view addSubview:slider];
    [self.view addSubview:draggable];
    
    [self.view addSubview:ul];
    [self.view addSubview:ur];
    [self.view addSubview:br];
    [self.view addSubview:bl];
    
    adjust = draggable.frame.origin;
    
    [self setAnchorPoint:CGPointMake(0, 0) forView:draggable];
    [self didChangeTo:slider];
}

-(void) send:(UIView*)v to:(CGPoint)point{
    CGRect fr = v.frame;
    fr.origin = CGPointMake(adjust.x + point.x - v.bounds.size.width/2,
                            adjust.y + point.y - v.bounds.size.height/2);
    v.frame = fr;
}

-(void) didChangeTo:(UISlider*)slider{
    Quadrilateral q1, q2;
    
    CGFloat val = slider.value;
    
    q1.upperLeft = CGPointMake(0, 0);
    q1.upperRight = CGPointMake(draggable.bounds.size.width, 0);
    q1.lowerRight = CGPointMake(draggable.bounds.size.width, draggable.bounds.size.height);
    q1.lowerLeft = CGPointMake(0, draggable.bounds.size.height);
    
    q2.upperLeft = CGPointMake(140*val,75*val);
    q2.upperRight = CGPointMake(draggable.bounds.size.width * (1 - .2*val), 350*val);
    q2.lowerRight = CGPointMake(draggable.bounds.size.width * (1 + .3*val), draggable.bounds.size.height * (1 + .5*val));
    q2.lowerLeft = CGPointMake(-10*val, draggable.bounds.size.height * (1 + .3*val));
    
    [self send:ul to:q2.upperLeft];
    [self send:ur to:q2.upperRight];
    [self send:br to:q2.lowerRight];
    [self send:bl to:q2.lowerLeft];
    
    
    CATransform3D skewTransform = [MMStretchGestureRecognizer transformQuadrilateral:q1 toQuadrilateral:q2];
    
    
    [self setAnchorPoint:CGPointMake(0, 0) forView:draggable];
    draggable.layer.transform = skewTransform;
}

/**
 * this will set the anchor point for a scrap, so that it rotates
 * underneath the gesture realistically, instead of always from
 * it's center
 */
-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
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
