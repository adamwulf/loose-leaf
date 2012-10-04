//
//  PaintingSampleViewController.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingSampleViewController.h"
#import "NSThread+BlockAdditions.h"
#import "UIImage+Scale.h"

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

    //
    // create the canvas, clear by default
    CGRect paintFrame = self.view.bounds;
    canvas = [[PaintView alloc] initWithFrame:paintFrame];
    [container addSubview:canvas];
    [canvas release];
    [canvas setNeedsDisplay];

    
    
    //
    // create two images to draw over
    UIImage* marsImg = [UIImage maxResolutionImageNamed:@"mars.png"];
    mars1 = [[PaintableImageView alloc] initWithImage:marsImg];
    CGRect fr = mars1.frame;
    fr.origin.y = 200;
    fr.origin.x = 150;
    mars1.frame = fr;
    [container addSubview:mars1];
    mars2 = [[PaintableImageView alloc] initWithImage:marsImg];
    fr = mars2.frame;
    fr.origin.y = 282;
    fr.origin.x = 200;
    mars2.frame = fr;
    mars2.alpha = .5;
    [container addSubview:mars2];
    mars3 = [[PaintableImageView alloc] initWithImage:marsImg];
    fr = mars3.frame;
    fr.origin.y = 482;
    fr.origin.x = 200;
    mars3.frame = fr;
    mars3.clipPath = [UIBezierPath bezierPathWithOvalInRect:mars3.bounds];
    [container addSubview:mars3];
    
    
    
    ////////////////////////////////////
    //
    // donut shape
    mars4 = [[PaintableImageView alloc] initWithImage:marsImg];
    fr = mars4.frame;
    fr.origin.y = 582;
    fr.origin.x = 400;
    mars4.frame = fr;

    //
    // create a circular donut
    UIBezierPath* donut = [UIBezierPath bezierPath];
    [donut appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(mars4.bounds.size.width/2, mars4.bounds.size.height/2) radius:mars4.bounds.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    [donut appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(mars4.bounds.size.width/2, mars4.bounds.size.height/2) radius:mars4.bounds.size.width/2-40 startAngle:0 endAngle:2*M_PI clockwise:YES]];
    
    //
    // or create a square donut
    /*
    UIBezierPath* donut = [UIBezierPath bezierPath];
    [donut moveToPoint:CGPointZero];
    [donut addLineToPoint:CGPointMake(mars4.bounds.size.width, 0)];
    [donut addLineToPoint:CGPointMake(mars4.bounds.size.width, mars4.bounds.size.height)];
    [donut addLineToPoint:CGPointMake(0, mars4.bounds.size.height)];
    [donut addLineToPoint:CGPointZero];
    [donut moveToPoint:CGPointMake(40, 40)];
    [donut addLineToPoint:CGPointMake(40, mars4.bounds.size.height-40)];
    [donut addLineToPoint:CGPointMake(mars4.bounds.size.width-40, mars4.bounds.size.height-40)];
    [donut addLineToPoint:CGPointMake(mars4.bounds.size.width-40, 40)];
    [donut addLineToPoint:CGPointMake(40, 40)];
     */
    mars4.clipPath = donut;
    [container addSubview:mars4];
    //
    // enddonut shape
    //
    ////////////////////////////////////


    // rotation
    //
    // test rotation on an image
    mars2.transform = CGAffineTransformMakeRotation(.4);
    mars4.transform = CGAffineTransformMakeRotation(-0.3);

    
    //
    // handle painting events
    paintTouch = [[PaintTouchView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paintTouch];
    [paintTouch release];
    [paintTouch setDelegate:self];
    
    // add the container for all the views
    [self.view addSubview:container];
    
    //
    // button to toggle the paint event capture
    UIButton* button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _switch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 10, 80, 40)];
    [_switch addTarget: self
                  action: @selector(switchChanged:)
        forControlEvents: UIControlEventValueChanged];
    _switch.on = YES;
    [self.view addSubview:_switch];
    
    [canvas setDelegate:self];
    [mars1 setDelegate:self];
    [mars2 setDelegate:self];
    [mars3 setDelegate:self];
    [mars4 setDelegate:self];
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
            /**
             * commenting out this optimization for now
             * to focus on correctness
             *
            if([((NSObject<PaintTouchViewDelegate>*)v) fullyContainsArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth fromView:view]){
                break;
            }
             */
        }
    }
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [canvas drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars1 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars2 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars3 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
    [mars4 drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [canvas drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars1 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars2 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars3 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
    [mars4 drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
}

-(BOOL) fullyContainsArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    return YES;
}


#pragma mark - PaintableViewDelegate

-(NSArray*) paintableViewsAbove:(UIView*)aView{
    if(aView == mars3){
        return [NSArray arrayWithObject:mars4];
    }else if(aView == mars2){
        return [NSArray arrayWithObjects:mars3, mars4, nil];
    } else if(aView == mars1){
        return [NSArray arrayWithObjects:mars2, mars3, mars4, nil];
    }else if(aView == canvas){
        return [NSArray arrayWithObjects:mars1, mars2, mars3, mars4, nil];
    }
    return [NSArray array];
}
-(BOOL) shouldDrawClipPath{
    return _switch.on;
}

-(void) switchChanged:(UISwitch*)_aSwitch{
    [canvas setNeedsDisplay];
    [mars1 setNeedsDisplay];
    [mars2 setNeedsDisplay];
    [mars3 setNeedsDisplay];
    [mars4 setNeedsDisplay];
}

-(CGAffineTransform) transform{
    return CGAffineTransformIdentity;
}


@end
