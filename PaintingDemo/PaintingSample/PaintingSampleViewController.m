//
//  PaintingSampleViewController.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingSampleViewController.h"
#import "NSThread+BlockAdditions.h"

@implementation PaintingSampleViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // setup container for other views
    container = [[UIView alloc] initWithFrame:self.view.bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];

    //
    // create the paint view, clear by default
    CGRect paintFrame = self.view.bounds;
    paint = [[PaintView alloc] initWithFrame:paintFrame];
    [container addSubview:paint];
    [paint release];

    //
    // mars images
    UIImage* marsImg = [UIImage imageNamed:@"mars.png"];
//    if([[UIScreen mainScreen] scale] != 1.0){
        // load images at high resolution
        marsImg = [UIImage imageWithCGImage:marsImg.CGImage scale:2.0 orientation:marsImg.imageOrientation];
//    }
    mars1 = [[PaintableImageView alloc] initWithImage:marsImg];
    CGRect fr = mars1.frame;
    fr.origin.y = 200;
    fr.origin.x = 150;
    mars1.frame = fr;
    mars2 = [[PaintableImageView alloc] initWithImage:marsImg];
    fr = mars2.frame;
    fr.origin.y = 282;
    fr.origin.x = 200;
    mars2.frame = fr;
    mars2.alpha = .5;
    [container addSubview:mars1];
    [container addSubview:mars2];
    
    for(int i=0;i<0;i++){
        PaintableImageView* view = [[PaintableImageView alloc] initWithImage:marsImg];
        CGRect fr = mars2.frame;
        fr.origin.x += rand() % 50;
        fr.origin.y += rand() % 50;
        view.frame = fr;
        [container addSubview:view];
        
    }
    
//    mars2.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(.3), CGAffineTransformMakeScale(2.0, 2.0));
    mars2.transform = CGAffineTransformMakeRotation(.4);
    
    // add the container for all the views
    [self.view addSubview:container];

    
    // ok, catch the touches on top of all the views
    
    paintTouch = [[PaintTouchView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paintTouch];
    [paintTouch release];
    
    [paintTouch setDelegate:self];
    
    
    UIButton* button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    
    
    
    //
    //
    // TEST CODE
    //
    // this code is helping me define bezier paths for 2 views that intersect
    //
    // the definitelyNotVisiblePath is what should be returned from the view
    // that is hiding another view. this bezier path will then be used to
    // slice out a hole in any view underneath it.
    if(YES){
        
        // first, convert the top view into the bottom view's coordinate system
        CGRect coveringViewRect = [mars1 convertRect:mars2.rotationlessFrame fromView:mars2.superview];
        
        //
        // first, define the path that could possibly be visible:
        UIBezierPath* possiblyVisiblePath = [UIBezierPath bezierPath];
        [possiblyVisiblePath appendPath:[UIBezierPath bezierPathWithRect:mars1.bounds]];
        
        //
        // the definitely not visible path needs to be
        // in the reverse direction so that it cuts out a hole
        // of the possiblyVisiblePath (effectively making the
        // possible visible area less than or equal to itself)
        UIBezierPath *definitelyNotVisiblePath = [UIBezierPath bezierPath];
        [definitelyNotVisiblePath moveToPoint:CGPointMake(coveringViewRect.origin.x, coveringViewRect.origin.y)];
        [definitelyNotVisiblePath addLineToPoint:CGPointMake(coveringViewRect.origin.x, coveringViewRect.origin.y + coveringViewRect.size.height)];
        [definitelyNotVisiblePath addLineToPoint:CGPointMake(coveringViewRect.origin.x + coveringViewRect.size.width, coveringViewRect.origin.y + coveringViewRect.size.height)];
        [definitelyNotVisiblePath addLineToPoint:CGPointMake(coveringViewRect.origin.x + coveringViewRect.size.width, coveringViewRect.origin.y)];
        [definitelyNotVisiblePath closePath];
        
        [definitelyNotVisiblePath applyTransform:CGAffineTransformMakeTranslation(-coveringViewRect.origin.x-coveringViewRect.size.width / 2, -coveringViewRect.origin.y-coveringViewRect.size.height / 2)];
        [definitelyNotVisiblePath applyTransform:CGAffineTransformMakeRotation(0.4)];
        [definitelyNotVisiblePath applyTransform:CGAffineTransformMakeTranslation(coveringViewRect.origin.x + coveringViewRect.size.width / 2, coveringViewRect.origin.y + coveringViewRect.size.height / 2)];
        
        //
        // now add that path to crop out the invisible area
        [possiblyVisiblePath appendPath:definitelyNotVisiblePath];
        
        //
        // create a mask layer from the bezier curve
        // that defines the edge of all views that hide our content.
        // (in this demo case, just 1 view's path, the definitelyNotVisiblePath)
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        maskLayer.contentsScale = scale;
        maskLayer.frame = mars1.layer.bounds;
        maskLayer.fillColor = [UIColor greenColor].CGColor; // needs to be opaque
        maskLayer.backgroundColor = [UIColor clearColor].CGColor; // needs to be clear
        maskLayer.path = possiblyVisiblePath.CGPath;
//        maskLayer.borderColor = [UIColor purpleColor].CGColor;
//        maskLayer.borderWidth = 1;
//        maskLayer.lineWidth = 1;
//        maskLayer.strokeColor = [UIColor orangeColor].CGColor;
//        [mars1.layer addSublayer:maskLayer]; // used for debugging
        mars1.layer.mask = maskLayer;
        
        
        
        /*
         * debugging:
         * mark the corners of mars 2 inside of mars 1 layers
         // corner
        CALayer* point1L = [CALayer layer];
        point1L.frame = CGRectMake(pointInLayer.x-5, pointInLayer.y-5, 10, 10);
        point1L.backgroundColor = [UIColor blueColor].CGColor;
        [mars1.layer addSublayer:point1L];
        
         // corner
        CALayer* point2L = [CALayer layer];
        point2L.frame = CGRectMake(pointInLayer2.x-5, pointInLayer2.y-5, 10, 10);
        point2L.backgroundColor = [UIColor orangeColor].CGColor;
        [mars1.layer addSublayer:point2L];

        // center
        CALayer* point3L = [CALayer layer];
        point3L.frame = CGRectMake(coveringViewRect.origin.x + coveringViewRect.size.width/2-5, coveringViewRect.origin.y + coveringViewRect.size.height/2 - 5, 10, 10);
        point3L.backgroundColor = [UIColor orangeColor].CGColor;
        [mars1.layer addSublayer:point3L];
         */
        
    }
}


-(void) toggle{
    paintTouch.hidden = !paintTouch.hidden;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - PaintTouchViewDelegate

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    for(UIView* v in [container.subviews reverseObjectEnumerator]){
        if([v respondsToSelector:@selector(drawArcAtStart:end:controlPoint1:controlPoint2:withFingerWidth:fromView:)]){
            [(NSObject<PaintTouchViewDelegate>*)v drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth fromView:view];
            if([((NSObject<PaintTouchViewDelegate>*)v) fullyContainsArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth fromView:view]){
                break;
            }
        }
    }
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [paint drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars1 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars2 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [paint drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars1 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars2 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
}

-(BOOL) fullyContainsArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    return YES;
}


@end
