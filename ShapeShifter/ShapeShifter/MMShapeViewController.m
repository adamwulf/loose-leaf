//
//  MMShapeViewController.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMShapeViewController.h"
#import "MMDebugQuadrilateralView.h"
#import "MMStretchGestureRecognizer1.h"
#import "MMStretchGestureRecognizer2.h"
#import "MMStretchGestureRecognizer3.h"
#import "Constants.h"

@implementation MMShapeViewController{
    MMDebugQuadrilateralView* debugView;
    UIImageView* draggable;
    MMStretchGestureRecognizer1* gesture1;
    MMStretchGestureRecognizer2* gesture2;
    MMStretchGestureRecognizer3* gesture3;
    
    UIView* ul;
    UIView* ur;
    UIView* br;
    UIView* bl;
    
    CGPoint adjust;
    
    
    Quadrilateral firstQ;
    
    UILabel* convexLabel;
}

const int INDETERMINANT = 0;
const int CONCAVE = -1;
const int CONVEX = 1;
const int COLINEAR = 0;


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
    
    UISegmentedControl* gestureChooser = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"exact", @"average", @"oriented", nil]];
    [gestureChooser addTarget:self action:@selector(chooseGesture:) forControlEvents:UIControlEventValueChanged];
    
    debugView = [[MMDebugQuadrilateralView alloc] initWithFrame:self.view.bounds];
    
    convexLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 700, 100, 30)];
    convexLabel.backgroundColor = [UIColor whiteColor];
    
    draggable = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 300, 200)];
    draggable.contentMode = UIViewContentModeScaleAspectFill;
//    draggable.clipsToBounds = YES;
    draggable.image = [UIImage imageNamed:@"space.jpg"];

    
    ul = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ul.backgroundColor = [UIColor redColor];
    ur = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ur.backgroundColor = [UIColor blueColor];
    br = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    br.backgroundColor = [UIColor purpleColor];
    bl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    bl.backgroundColor = [UIColor greenColor];

    gesture1 = [[MMStretchGestureRecognizer1 alloc] initWithTarget:self action:@selector(didStretch:)];
    gesture2 = [[MMStretchGestureRecognizer2 alloc] initWithTarget:self action:@selector(didStretch:)];
    gesture3 = [[MMStretchGestureRecognizer3 alloc] initWithTarget:self action:@selector(didStretch:)];
    [self.view addGestureRecognizer:gesture1];
    [self.view addGestureRecognizer:gesture2];
    [self.view addGestureRecognizer:gesture3];
    self.view.userInteractionEnabled = YES;
    
    [self.view addSubview:draggable];
    
    [self.view addSubview:ul];
    [self.view addSubview:ur];
    [self.view addSubview:br];
    [self.view addSubview:bl];
    
    adjust = draggable.frame.origin;

    [self setAnchorPoint:CGPointMake(0, 0) forView:draggable];
    [self.view addSubview:debugView];
    [debugView addSubview:convexLabel];
    [self.view addSubview:gestureChooser];
    
    gestureChooser.frame = CGRectMake(100, 50, 300, 50);
    gestureChooser.selectedSegmentIndex = 2;
    [self chooseGesture:gestureChooser];
}

-(void) chooseGesture:(UISegmentedControl*)control{
    if(control.selectedSegmentIndex == 0){
        gesture1.enabled = YES;
        gesture2.enabled = NO;
        gesture3.enabled = NO;
    }else if(control.selectedSegmentIndex == 1){
        gesture1.enabled = NO;
        gesture2.enabled = YES;
        gesture3.enabled = NO;
    }else if(control.selectedSegmentIndex == 2){
        gesture1.enabled = NO;
        gesture2.enabled = NO;
        gesture3.enabled = YES;
    }
}

-(void) send:(UIView*)v to:(CGPoint)point{
    CGRect fr = v.frame;
    fr.origin = CGPointMake(point.x - v.bounds.size.width/2,
                            point.y - v.bounds.size.height/2);
    v.frame = fr;
}

-(void) updateLabelFor:(Quadrilateral)q2{
    NSString* text = @"co-linear";
    CGPoint points[4];
    points[0] = q2.upperLeft;
    points[1] = q2.upperRight;
    points[2] = q2.lowerRight;
    points[3] = q2.lowerLeft;
    
    int convexTest = Convex(points);
    if(convexTest == CONVEX){
        text = @"convex";
    }else if(convexTest == CONCAVE){
        text = @"concave";
    }else{
        text = @"co-linear";
    }
    
    convexLabel.text = text;
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


-(void) didStretch:(MMStretchGestureRecognizer1*)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
//        NSLog(@"began");
        firstQ = [gesture getQuad];
    }else if(gesture.state == UIGestureRecognizerStateCancelled){
//        NSLog(@"cancelled");
        draggable.layer.transform = CATransform3DIdentity;
    }else if(gesture.state == UIGestureRecognizerStateChanged){
//        NSLog(@"changed");
        Quadrilateral secondQ = [gesture getQuad];

        [self send:ul to:secondQ.upperLeft];
        [self send:ur to:secondQ.upperRight];
        [self send:br to:secondQ.lowerRight];
        [self send:bl to:secondQ.lowerLeft];
        
        [self updateLabelFor:secondQ];
        [debugView setQuadrilateral:secondQ];

        Quadrilateral q1 = [self adjustedQuad:firstQ by:adjust];
        Quadrilateral q2 = [self adjustedQuad:secondQ by:adjust];
        
        CATransform3D skewTransform = [MMStretchGestureRecognizer1 transformQuadrilateral:q1 toQuadrilateral:q2];
        
        draggable.layer.transform = skewTransform;

        
        
    }else if(gesture.state == UIGestureRecognizerStateEnded){
//        NSLog(@"ended");
        draggable.layer.transform = CATransform3DIdentity;
    }else if(gesture.state == UIGestureRecognizerStateFailed){
//        NSLog(@"failed");
        draggable.layer.transform = CATransform3DIdentity;
    }else if(gesture.state == UIGestureRecognizerStatePossible){
//        NSLog(@"possible");
        draggable.layer.transform = CATransform3DIdentity;
    }
}

-(Quadrilateral) adjustedQuad:(Quadrilateral)a by:(CGPoint)p{
    Quadrilateral output = a;
    output.upperLeft.x -= p.x;
    output.upperLeft.y -= p.y;
    output.upperRight.x -= p.x;
    output.upperRight.y -= p.y;
    output.lowerRight.x -= p.x;
    output.lowerRight.y -= p.y;
    output.lowerLeft.x -= p.x;
    output.lowerLeft.y -= p.y;
    
    return output;
}





/*
 Return whether a polygon in 2D is concave or convex
 return 0 for incomputables eg: colinear points
 CONVEX == 1
 CONCAVE == -1
 It is assumed that the polygon is simple
 (does not intersect itself or have holes)
 */

int Convex(CGPoint p[4])
{
    int len = 4;
    int i,j,k;
    int flag = 0;
    double z;
    
    for (i=0;i<len;i++) {
        j = (i + 1) % len;
        k = (i + 2) % len;
        z  = (p[j].x - p[i].x) * (p[k].y - p[j].y);
        z -= (p[j].y - p[i].y) * (p[k].x - p[j].x);
        if (z == 0){
            return(COLINEAR);
        }else if (z < 0){
            flag |= 1;
        }else if (z > 0){
            flag |= 2;
        }
        if (flag == 3){
            return(CONCAVE);
        }
    }
    if (flag != 0)
        return(CONVEX);
    else
        return(0);
}
@end
