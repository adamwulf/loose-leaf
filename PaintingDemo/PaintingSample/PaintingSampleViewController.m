//
//  PaintingSampleViewController.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingSampleViewController.h"
#import "PaintView.h"
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
    UIView* container = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView* otherviews = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImage* marsImg = [UIImage imageNamed:@"mars.jpeg"];
    if([[UIScreen mainScreen] scale] != 1.0){
        // load images at high resolution
        marsImg = [UIImage imageWithCGImage:marsImg.CGImage scale:[[UIScreen mainScreen] scale] orientation:marsImg.imageOrientation];
    }
    UIImageView* mars1 = [[UIImageView alloc] initWithImage:marsImg];
    UIImageView* mars2 = [[UIImageView alloc] initWithImage:marsImg];
    [otherviews addSubview:mars1];
    [otherviews addSubview:mars2];
    CGRect fr = mars2.frame;
    fr.origin.y = self.view.bounds.size.height / 2;
    mars2.frame = fr;
    

    [container addSubview:otherviews];

    //
    // create the paint view, clear by default
    PaintView *paint = [[PaintView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paint];
    [paint release];

    [self.view addSubview:container];
    
    /*
    [NSThread performBlockInBackground:^{
        //
        // create the background image to put behind
        // the paint view
        //
        // this code is NOT safe
        //
        // TODO
        // i'll have to create a render engine i guess, and render a page
        // in the background not including teh current inking, then
        // composite that ink down (?)
        //
        // but then using two fingers to move a layer while while ink is
        // active will be difficult/impossible. i think just using
        // transparency might be the way to go
        UIGraphicsBeginImageContextWithOptions(otherviews.bounds.size, otherviews.opaque, 0.0);
        [otherviews.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [NSThread performBlockOnMainThread:^{
            [paint setBackgroundColor:[UIColor colorWithPatternImage:snapshot]];
        }];
    }];
     */
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

@end
