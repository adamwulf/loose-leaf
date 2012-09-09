//
//  PaintingSampleViewController.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingSampleViewController.h"
#import "PaintTouchView.h"
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
    
    //
    // create the paint view, clear by default
    paint = [[PaintView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paint];
    [paint release];

    //
    // mars images
    UIImage* marsImg = [UIImage imageNamed:@"mars.jpeg"];
    if([[UIScreen mainScreen] scale] != 1.0){
        // load images at high resolution
        marsImg = [UIImage imageWithCGImage:marsImg.CGImage scale:[[UIScreen mainScreen] scale] orientation:marsImg.imageOrientation];
    }
    mars1 = [[PaintableImageView alloc] initWithImage:marsImg];
    mars2 = [[PaintableImageView alloc] initWithImage:marsImg];
    CGRect fr = mars2.frame;
    fr.origin.y = self.view.bounds.size.height / 2;
    mars2.frame = fr;
    [container addSubview:mars1];
    [container addSubview:mars2];
    
    
    // add the container for all the views
    [self.view addSubview:container];

    
    // ok, catch the touches on top of all the views
    
    PaintTouchView *paintTouch = [[PaintTouchView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paintTouch];
    [paintTouch release];
    
    [paintTouch setDelegate:self];
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

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth{
    [paint drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth];
    [mars1 drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth];
    [mars2 drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth];
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth{
    [paint drawDotAtPoint:point withFingerWidth:fingerWidth];
    [mars1 drawDotAtPoint:point withFingerWidth:fingerWidth];
    [mars2 drawDotAtPoint:point withFingerWidth:fingerWidth];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth{
    [paint drawLineAtStart:start end:end withFingerWidth:fingerWidth];
    [mars1 drawLineAtStart:start end:end withFingerWidth:fingerWidth];
    [mars2 drawLineAtStart:start end:end withFingerWidth:fingerWidth];
}


@end
